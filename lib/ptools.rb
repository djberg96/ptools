require 'rbconfig'
require 'win32/file' if File::ALT_SEPARATOR

class File
  # The version of the ptools library.
  PTOOLS_VERSION = '1.5.0'.freeze

  # :stopdoc:

  # The WIN32EXTS string is used as part of a Dir[] call in certain methods.
  if File::ALT_SEPARATOR
    MSWINDOWS = true
    if ENV['PATHEXT']
      WIN32EXTS = String.new(".{#{ENV['PATHEXT'].tr(';', ',').tr('.', '')}}").downcase
    else
      WIN32EXTS = '.{exe,com,bat}'.freeze
    end
  else
    MSWINDOWS = false
  end

  if File::ALT_SEPARATOR
    private_constant :WIN32EXTS
    private_constant :MSWINDOWS
  end

  IMAGE_EXT = %w[.bmp .gif .jpg .jpeg .png .ico].freeze

  # :startdoc:

  # Returns whether or not the file is an image. Only JPEG, PNG, BMP,
  # GIF, TIFF, and ICO are checked against.
  #
  # This reads and checks the first few bytes of the file. For a version
  # that is more robust, but which depends on a 3rd party C library (and is
  # difficult to build on MS Windows), see the 'filemagic' library.
  #
  # By default the filename extension is also checked. You can disable this
  # by passing false as the second argument, in which case only the contents
  # are checked.
  #
  # Examples:
  #
  #    File.image?('somefile.jpg') # => true
  #    File.image?('somefile.txt') # => false
  #--
  # The approach I used here is based on information found at
  # http://en.wikipedia.org/wiki/Magic_number_(programming)
  #
  def self.image?(file, check_file_extension: true)
    magic_number_match = bmp?(file) || jpg?(file) || png?(file) || gif?(file) || tiff?(file) || ico?(file)

    return magic_number_match unless check_file_extension

    magic_number_match && IMAGE_EXT.include?(File.extname(file).downcase)
  end

  # Returns whether or not +file+ is a binary non-image file, i.e. executable,
  # shared object, etc.
  #
  # Internally this method simply looks for a double null sequence. This will
  # work for the vast majority of cases, but it is not guaranteed to be
  # absolutely accurate.
  #
  # Example:
  #
  #   File.binary?('somefile.exe') # => true
  #   File.binary?('somefile.txt') # => false
  #
  def self.binary?(file)
    return false if File.stat(file).zero?
    return false if image?(file)
    return false if check_bom?(file)

    bytes = File.stat(file).blksize
    bytes = 4096 if bytes > 4096
    content = File.read(file, bytes) || ''
    content.include?("\u0000\u0000")
  end

  # Looks for the first occurrence of +program+ within +path+.
  #
  # On Windows, it looks for executables ending with the suffixes defined
  # in your PATHEXT environment variable, or '.exe', '.bat' and '.com' if
  # that isn't defined, which you may optionally include in +program+.
  #
  # Returns nil if not found.
  #
  # Examples:
  #
  #   File.which('ruby') # => '/usr/local/bin/ruby'
  #   File.which('foo')  # => nil
  #
  def self.which(program, path = ENV.fetch('PATH', nil))
    raise ArgumentError, 'program cannot be empty' if program.nil? || program.empty?
    raise ArgumentError, 'path cannot be empty' if path.nil? || path.empty?

    # Bail out early if an absolute path is provided.
    if program =~ /^\/|^[a-z]:[\\\/]/i
      return find_executable_in_absolute_path(program)
    end

    # Iterate over each path glob the dir + program.
    path.split(File::PATH_SEPARATOR).each do |dir|
      dir = File.expand_path(dir)
      next unless File.exist?(dir) # In case of bogus second argument

      found = find_executable_in_directory(dir, program)
      return found if found
    end

    nil
  end

  # Returns an array of each +program+ within +path+, or nil if it cannot
  # be found.
  #
  # On Windows, it looks for executables ending with the suffixes defined
  # in your PATHEXT environment variable, or '.exe', '.bat' and '.com' if
  # that isn't defined, which you may optionally include in +program+.
  #
  # Examples:
  #
  #   File.whereis('ruby') # => ['/usr/bin/ruby', '/usr/local/bin/ruby']
  #   File.whereis('foo')  # => nil
  #
  def self.whereis(program, path = ENV.fetch('PATH', nil))
    raise ArgumentError, 'program cannot be empty' if program.nil? || program.empty?
    raise ArgumentError, 'path cannot be empty' if path.nil? || path.empty?

    paths = []

    # Bail out early if an absolute path is provided.
    if program =~ /^\/|^[a-z]:[\\\/]/i
      found = find_all_executables_in_absolute_path(program)
      return found.empty? ? nil : found
    end

    # Iterate over each path glob the dir + program.
    path.split(File::PATH_SEPARATOR).each do |dir|
      next unless File.exist?(dir) # In case of bogus second argument

      found = find_executable_in_directory(dir, program)
      paths << found if found
    end

    paths.empty? ? nil : paths.uniq
  end

  # In block form, yields the first +num_lines+ from +filename+.  In non-block
  # form, returns an Array of +num_lines+
  #
  # Examples:
  #
  #  # Return an array
  #  File.head('somefile.txt') # => ['This is line1', 'This is line2', ...]
  #
  #  # Use a block
  #  File.head('somefile.txt'){ |line| puts line }
  #
  def self.head(filename, num_lines = 10)
    raise ArgumentError, 'num_lines must be non-negative' if num_lines < 0
    return [] if num_lines == 0

    lines = []

    File.foreach(filename) do |line|
      break if lines.size >= num_lines

      if block_given?
        yield line
      else
        lines << line
      end
    end

    block_given? ? nil : lines
  end

  # In block form, yields the last +num_lines+ of file +filename+.
  # In non-block form, it returns the lines as an array.
  #
  # Example:
  #
  #   File.tail('somefile.txt') # => ['This is line7', 'This is line8', ...]
  #
  # If you're looking for tail -f functionality, please use the file-tail
  # gem instead.
  #
  #--
  # Internally I'm using a 64 chunk of memory at a time. I may allow the size
  # to be configured in the future as an optional 3rd argument.
  #
  def self.tail(filename, num_lines = 10, &block)
    tail_size = 2**16 # 64k chunks

    # MS Windows gets unhappy if you try to seek backwards past the
    # end of the file, so we have some extra checks here and later.
    file_size  = File.size(filename)
    read_bytes = file_size % tail_size
    read_bytes = tail_size if read_bytes == 0

    line_sep = File::ALT_SEPARATOR ? "\r\n" : "\n"

    buf = ''

    # Open in binary mode to ensure line endings aren't converted.
    File.open(filename, 'rb') do |fh|
      position = file_size - read_bytes # Set the starting read position

      # Loop until we have the lines or run out of file
      while buf.scan(line_sep).size <= num_lines and position >= 0
        fh.seek(position, IO::SEEK_SET)
        buf = fh.read(read_bytes) + buf
        read_bytes = tail_size
        position -= read_bytes
      end
    end

    lines = buf.split(line_sep).pop(num_lines)

    if block_given?
      lines.each(&block)
    else
      lines
    end
  end

  # Converts a text file from one OS platform format to another, ala
  # 'dos2unix'. The possible values for +platform+ include:
  #
  # * MS Windows -> dos, windows, win32, mswin
  # * Unix/BSD   -> unix, linux, bsd, osx, darwin, sunos, solaris
  # * Mac        -> mac, macintosh, apple
  #
  # You may also specify 'local', in which case your CONFIG['host_os'] value
  # will be used. This is the default.
  #
  # Note that this method is only valid for an ftype of "file". Otherwise a
  # TypeError will be raised. If an invalid format value is received, an
  # ArgumentError is raised.
  #
  def self.nl_convert(old_file, new_file = old_file, platform = 'local')
    raise ArgumentError, 'Only valid for plain text files' unless File::Stat.new(old_file).file?

    format = nl_for_platform(platform)

    if old_file == new_file
      require 'tempfile'
      temp_name = Time.new.strftime('%Y%m%d%H%M%S')
      nf = Tempfile.new("ruby_temp_#{temp_name}")
    else
      nf = File.new(new_file, 'w')
    end

    begin
      nf.open if old_file == new_file
      File.foreach(old_file) do |line|
        line.chomp!
        nf.print("#{line}#{format}")
      end
    ensure
      nf.close if nf && !nf.closed?
      if old_file == new_file
        require 'fileutils'
        File.delete(old_file)
        FileUtils.mv(nf.path, old_file)
      end
    end

    self
  end

  # Changes the access and modification time if present, or creates a 0
  # byte file +filename+ if it doesn't already exist.
  #
  def self.touch(filename)
    raise ArgumentError, 'filename cannot be nil or empty' if filename.nil? || filename.empty?

    if File.exist?(filename)
      time = Time.now
      File.utime(time, time, filename)
    else
      File.open(filename, 'w') {}
    end
    self
  end

  # With no arguments, returns a four element array consisting of the number
  # of bytes, characters, words and lines in filename, respectively.
  #
  # Valid options are 'bytes', 'characters' (or just 'chars'), 'words' and
  # 'lines'.
  #
  def self.wc(filename, option = 'all')
    option = option.to_s.downcase
    valid = %w[all bytes characters chars lines words]

    raise ArgumentError, "Invalid option: '#{option}'" unless valid.include?(option)

    case option
    when 'lines'
      count_lines(filename)
    when 'bytes'
      File.size(filename)
    when 'characters', 'chars'
      count_characters(filename)
    when 'words'
      count_words(filename)
    else
      count_all_stats(filename)
    end
  rescue Errno::ENOENT, Errno::EACCES
    option == 'all' ? [0, 0, 0, 0] : 0
  end

  # Already provided by win32-file on MS Windows
  unless respond_to?(:sparse?)
    # Returns whether or not +file+ is a sparse file.
    #
    # A sparse file is a any file where its size is greater than the number
    # of 512k blocks it consumes, i.e. its apparent and actual file size is
    # not the same.
    #
    # See http://en.wikipedia.org/wiki/Sparse_file for more information.
    #
    def self.sparse?(file)
      stats = File.stat(file)
      stats.size > stats.blocks * 512
    rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
      false
    end
  end

  # Returns whether or not the given +text+ contains a BOM marker.
  # If present, we can generally assume it's a text file.
  #
  def self.check_bom?(file)
    return false if File.zero?(file)

    text = File.read(file, 4).force_encoding('utf-8')

    # Check for UTF-8 BOM
    return true if text.bytesize >= 3 && text[0, 3] == "\xEF\xBB\xBF"

    # Check for UTF-32 BOM (both byte orders)
    return true if text.bytesize >= 4 && (text[0, 4] == "\x00\x00\xFE\xFF" || text[0, 4] == "\xFF\xFE\x00\x00")

    # Check for UTF-16 BOM (both byte orders)
    return true if text.bytesize >= 2 && (text[0, 2] == "\xFF\xFE" || text[0, 2] == "\xFE\xFF")

    false
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  private_class_method :check_bom?

  # Returns the newline characters for the given platform.
  #
  def self.nl_for_platform(platform)
    platform = RbConfig::CONFIG['host_os'] if platform == 'local'

    case platform
      when /dos|windows|win32|mswin|mingw/i
        "\cM\cJ"
      when /unix|linux|bsd|cygwin|osx|darwin|solaris|sunos/i
        "\cJ"
      when /mac|apple|macintosh/i
        "\cM"
      else
        raise ArgumentError, 'Invalid platform string'
    end
  end

  # Is the file a bitmap file?
  #
  def self.bmp?(file)
    return false if File.size(file) < 6

    data = File.read(file, 6, nil, encoding: 'binary')
    data[0, 2] == 'BM' && File.size(file) == data[2, 4].unpack1('i')
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  # Is the file a jpeg file?
  #
  def self.jpg?(file)
    return false if File.size(file) < 10

    data = File.read(file, 10, nil, encoding: 'binary')
    data == String.new("\377\330\377\340\000\020JFIF").force_encoding(Encoding::BINARY)
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  # Is the file a png file?
  #
  def self.png?(file)
    return false if File.size(file) < 4

    data = File.read(file, 4, nil, encoding: 'binary')
    data == String.new("\211PNG").force_encoding(Encoding::BINARY)
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  # Is the file a gif?
  #
  def self.gif?(file)
    return false if File.size(file) < 6

    header = File.read(file, 6)
    %w[GIF89a GIF97a].include?(header)
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  # Is the file a tiff?
  #
  def self.tiff?(file)
    return false if File.size(file) < 4

    bytes = File.read(file, 4)

    # II is Intel, MM is Motorola
    return false unless %w[II MM].include?(bytes[0..1])

    # Check magic number based on endianness
    case bytes[0..1]
    when 'II'
      bytes[2..3].unpack1('v') == 42  # Little endian
    when 'MM'
      bytes[2..3].unpack1('n') == 42  # Big endian
    else
      false
    end
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  # Is the file an ico file?
  #
  def self.ico?(file)
    return false if File.size(file) < 4

    data = File.read(file, 4, nil, encoding: 'binary')
    ["\000\000\001\000", "\000\000\002\000"].include?(data)
  rescue Errno::EACCES, Errno::EISDIR, Errno::ELOOP
    false
  end

  private_class_method :check_bom?

  # Helper method for finding executable in absolute path
  def self.find_executable_in_absolute_path(program)
    program += WIN32EXTS if MSWINDOWS && File.extname(program).empty?
    found = Dir[program].first
    if found && File.executable?(found) && !File.directory?(found)
      return found
    end
    nil
  end

  # Helper method for finding all executables in absolute path
  def self.find_all_executables_in_absolute_path(program)
    program += WIN32EXTS if MSWINDOWS && File.extname(program).empty?
    program = program.tr(File::ALT_SEPARATOR, File::SEPARATOR) if MSWINDOWS
    found = Dir[program].select { |f| File.executable?(f) && !File.directory?(f) }

    if File::ALT_SEPARATOR
      found.map { |f| f.tr(File::SEPARATOR, File::ALT_SEPARATOR) }
    else
      found
    end
  end

  # Helper method for finding executable in directory
  def self.find_executable_in_directory(dir, program)
    file = File.join(dir, program)

    # Dir[] doesn't handle backslashes properly, so convert them. Also, if
    # the program name doesn't have an extension, try them all.
    if MSWINDOWS
      file = file.tr(File::ALT_SEPARATOR, File::SEPARATOR)
      file += WIN32EXTS if File.extname(program).empty?
    end

    found = Dir[file].first

    # Convert all forward slashes to backslashes if supported
    if found && File.executable?(found) && !File.directory?(found)
      found.tr!(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
      return found
    end
    nil
  end

  # Helper method for counting lines
  def self.count_lines(filename)
    count = 0
    File.foreach(filename) { count += 1 }
    count
  end

  # Helper method for counting characters efficiently
  def self.count_characters(filename)
    File.read(filename).length
  end

  # Helper method for counting words
  def self.count_words(filename)
    count = 0
    File.foreach(filename) do |line|
      count += line.split.length
    end
    count
  end

  # Helper method for counting all statistics efficiently
  def self.count_all_stats(filename)
    bytes = File.size(filename)
    lines = words = chars = 0

    File.foreach(filename) do |line|
      lines += 1
      words += line.split.length
      chars += line.length
    end

    [bytes, chars, words, lines]
  end

  private_class_method :find_executable_in_absolute_path, :find_all_executables_in_absolute_path,
                       :find_executable_in_directory, :count_lines, :count_characters,
                       :count_words, :count_all_stats
end
