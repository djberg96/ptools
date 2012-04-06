require 'rbconfig'
require 'win32/file' if File::ALT_SEPARATOR

class File
  # The version of the ptools library.
  PTOOLS_VERSION = '1.2.2'

  # :stopdoc:

  # The WIN32EXTS string is used as part of a Dir[] call in certain methods.
  if File::ALT_SEPARATOR
    MSWINDOWS = true
    if ENV['PATHEXT']
      WIN32EXTS = ('.{' + ENV['PATHEXT'].tr(';', ',').tr('.','') + '}').downcase
    else
      WIN32EXTS = '.{exe,com,bat}'
    end
  else
    MSWINDOWS = false
  end

  IMAGE_EXT = %w[.bmp .gif .jpg .jpeg .png]

  # :startdoc:

  # Returns whether or not the file is an image. Only JPEG, PNG, BMP and
  # GIF are checked against.
  #
  # This method does some simple read and extension checks. For a version
  # that is more robust, but which depends on a 3rd party C library (and is
  # difficult to build on MS Windows), see the 'filemagic' library, available
  # on the RAA.
  #
  # Examples:
  #
  #    File.image?('somefile.jpg') # => true
  #    File.image?('somefile.txt') # => true
  #--
  # The approach I used here is based on information found at
  # http://en.wikipedia.org/wiki/Magic_number_(programming)
  #
  def self.image?(file)
    bool = IMAGE_EXT.include?(File.extname(file).downcase)      # Match ext
    bool = bmp?(file) || jpg?(file) || png?(file) || gif?(file) # Check data
    bool
  end

  # Returns the name of the null device (aka bitbucket) on your platform.
  #
  # Examples:
  #
  #   # On Linux
  #   File.null # => '/dev/null'
  #
  #   # On MS Windows
  #   File.null # => 'NUL'
  #--
  # The values I used here are based on information from
  # http://en.wikipedia.org/wiki//dev/null
  #
  def self.null
    case RbConfig::CONFIG['host_os']
      when /mswin|win32|msdos|cygwin|mingw|windows/i
        'NUL'
      when /amiga/i
        'NIL:'
      when /openvms/i
        'NL:'
      else
        '/dev/null'
    end
  end

  class << self
    alias null_device null
  end

  # Returns whether or not +file+ is a binary file.  Note that this is
  # not guaranteed to be 100% accurate.  It performs a "best guess" based
  # on a simple test of the first +File.blksize+ characters.
  #
  # Example:
  #
  #   File.binary?('somefile.exe') # => true
  #   File.binary?('somefile.txt') # => false
  #--
  # Based on code originally provided by Ryan Davis (which, in turn, is
  # based on Perl's -B switch).
  #
  def self.binary?(file)
    s = (File.read(file, File.stat(file).blksize) || "").split(//)
    ((s.size - s.grep(" ".."~").size) / s.size.to_f) > 0.30
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
  def self.which(program, path=ENV['PATH'])
    if path.nil? || path.empty?
      raise ArgumentError, "path cannot be empty"
    end

    # Bail out early if an absolute path is provided.
    if program =~ /^\/|^[a-z]:[\\\/]/i
      program += WIN32EXTS if MSWINDOWS && File.extname(program).empty?
      found = Dir[program].first
      if found && File.executable?(found) && !File.directory?(found)
        return found
      else
        return nil
      end
    end

    # Iterate over each path glob the dir + program.
    path.split(File::PATH_SEPARATOR).each{ |dir|
      next unless File.exists?(dir) # In case of bogus second argument
      file = File.join(dir, program)

      # Dir[] doesn't handle backslashes properly, so convert them. Also, if
      # the program name doesn't have an extension, try them all.
      if MSWINDOWS
        file = file.tr("\\", "/")
        file += WIN32EXTS if File.extname(program).empty?
      end

      found = Dir[file].first

      # Convert all forward slashes to backslashes if supported
      if found && File.executable?(found) && !File.directory?(found)
        found.tr!(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
        return found
      end
    }

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
  def self.whereis(program, path=ENV['PATH'])
    if path.nil? || path.empty?
      raise ArgumentError, "path cannot be empty"
    end

    paths = []

    # Bail out early if an absolute path is provided.
    if program =~ /^\/|^[a-z]:[\\\/]/i
      program += WIN32EXTS if MSWINDOWS && File.extname(program).empty?
      program = program.tr("\\", '/') if MSWINDOWS
      found = Dir[program]
      if found[0] && File.executable?(found[0]) && !File.directory?(found[0])
        if File::ALT_SEPARATOR
          return found.map{ |f| f.tr('/', "\\") }
        else
          return found
        end
      else
        return nil
      end
    end

    # Iterate over each path glob the dir + program.
    path.split(File::PATH_SEPARATOR).each{ |dir|
      next unless File.exists?(dir) # In case of bogus second argument
      file = File.join(dir, program)

      # Dir[] doesn't handle backslashes properly, so convert them. Also, if
      # the program name doesn't have an extension, try them all.
      if MSWINDOWS
        file = file.tr("\\", "/")
        file += WIN32EXTS if File.extname(program).empty?
      end

      found = Dir[file].first

      # Convert all forward slashes to backslashes if supported
      if found && File.executable?(found) && !File.directory?(found)
        found.tr!(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR
        paths << found
      end
    }

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
  def self.head(filename, num_lines=10)
    a = []

    IO.foreach(filename){ |line|
      break if num_lines <= 0
      num_lines -= 1
      if block_given?
        yield line
      else
        a << line
      end
    }

    return a.empty? ? nil : a # Return nil in block form
  end

  # In block form, yields line +from+ up to line +to+.  In non-block form
  # returns an Array of lines from +from+ to +to+.
  #
  def self.middle(filename, from=10, to=20)
    if block_given?
      IO.readlines(filename)[from-1..to-1].each{ |line| yield line }
    else
      IO.readlines(filename)[from-1..to-1]
    end
  end

  # In block form, yields the last +num_lines+ of file +filename+.
  # In non-block form, it returns the lines as an array.
  #
  # Note that this method slurps the entire file, so I don't recommend it
  # for very large files. Also note that 'tail -f' functionality is not
  # present. See the 'file-tail' library for that.
  #
  # Example:
  #
  #   File.tail('somefile.txt') # => ['This is line7', 'This is line8', ...]
  #
  def self.tail(filename, num_lines=10)
    if block_given?
      IO.readlines(filename).reverse[0..num_lines-1].reverse.each{ |line|
        yield line
      }
    else
      IO.readlines(filename).reverse[0..num_lines-1].reverse
    end
  end

  # Converts a text file from one OS platform format to another, ala
  # 'dos2unix'. The possible values for +platform+ include:
  #
  # * MS Windows -> dos, windows, win32, mswin
  # * Unix/BSD   -> unix, linux, bsd
  # * Mac        -> mac, macintosh, apple, osx
  #
  # Note that this method is only valid for an ftype of "file".  Otherwise a
  # TypeError will be raised.  If an invalid format value is received, an
  # ArgumentError is raised.
  #
  def self.nl_convert(old_file, new_file = old_file, platform = 'dos')
    unless File::Stat.new(old_file).file?
      raise ArgumentError, 'Only valid for plain text files'
    end

    case platform
      when /dos|windows|win32|mswin|cygwin|mingw/i
        format = "\cM\cJ"
      when /unix|linux|bsd/i
        format = "\cJ"
      when /mac|apple|macintosh|osx/i
        format = "\cM"
      else
        raise ArgumentError, "Invalid platform string"
    end

    orig = $\ # AKA $OUTPUT_RECORD_SEPARATOR
    $\ = format

    if old_file == new_file
      require 'fileutils'
      require 'tempfile'

      begin
        temp_name = Time.new.strftime("%Y%m%d%H%M%S")
        tf = Tempfile.new('ruby_temp_' + temp_name)
        tf.open

        IO.foreach(old_file){ |line|
          line.chomp!
          tf.print line
        }
      ensure
        tf.close if tf && !tf.closed?
      end

      File.delete(old_file)
      FileUtils.cp(tf.path, old_file)
    else
      begin
        nf = File.new(new_file, 'w')
        IO.foreach(old_file){ |line|
          line.chomp!
          nf.print line
        }
      ensure
        nf.close if nf && !nf.closed?
      end
    end

    $\ = orig
    self
  end

  # Changes the access and modification time if present, or creates a 0
  # byte file +filename+ if it doesn't already exist.
  #
  def self.touch(filename)
    if File.exists?(filename)
      time = Time.now
      File.utime(time, time, filename)
    else
      File.open(filename, 'w'){}
    end
    self
  end

  # With no arguments, returns a four element array consisting of the number
  # of bytes, characters, words and lines in filename, respectively.
  #
  # Valid options are 'bytes', 'characters' (or just 'chars'), 'words' and
  # 'lines'.
  #
  def self.wc(filename, option='all')
    option.downcase!
    valid = %w/all bytes characters chars lines words/

    unless valid.include?(option)
      raise ArgumentError, "Invalid option: '#{option}'"
    end

    n = 0

    if option == 'lines'
      IO.foreach(filename){ n += 1 }
      return n
    elsif option == 'bytes'
      File.open(filename){ |f|
        f.each_byte{ n += 1 }
      }
      return n
    elsif option == 'characters' || option == 'chars'
      File.open(filename){ |f|
        while f.getc
          n += 1
        end
      }
      return n
    elsif option == 'words'
      IO.foreach(filename){ |line|
        n += line.split.length
      }
      return n
    else
      bytes,chars,lines,words = 0,0,0,0
      IO.foreach(filename){ |line|
        lines += 1
        words += line.split.length
        chars += line.split('').length
      }
      File.open(filename){ |f|
        while f.getc
          bytes += 1
        end
      }
      return [bytes,chars,words,lines]
    end
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
    end
  end

  private

  def self.bmp?(file)
    IO.read(file, 3) == "BM6"
  end

  def self.jpg?(file)
    IO.read(file, 10) == "\377\330\377\340\000\020JFIF"
  end

  def self.png?(file)
    IO.read(file, 4) == "\211PNG"
  end

  def self.gif?(file)
    ['GIF89a', 'GIF97a'].include?(IO.read(file, 6))
  end
end
