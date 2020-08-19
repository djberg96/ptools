#####################################################################
# which_spec.rb
#
# Test case for the File.which method. You should run this test
# via 'rake spec' or 'rake spec --tag which'.
#####################################################################
require 'rspec'
require 'rbconfig'
require 'fileutils'
require 'ptools'
require 'tempfile'

describe File, :which do
  before(:context) do
    @windows = File::ALT_SEPARATOR
    @dir = File.join(Dir.pwd, 'tempdir')
    @non_exe = File.join(Dir.pwd, 'tempfile')
    @ruby = RUBY_PLATFORM.match('java') ? 'jruby' : 'ruby'
    @ruby = 'rbx' if defined?(Rubinius)

    Dir.mkdir(@dir) unless File.exist?(@dir)
    FileUtils.touch(@non_exe)
    File.chmod(775, @dir)
    File.chmod(644, @non_exe)

    @exe = File.join(
      RbConfig::CONFIG['bindir'],
      RbConfig::CONFIG['ruby_install_name']
    )

    if @windows
      @exe.tr!('/','\\')
      @exe << ".exe"
    end
  end

  example "which method basic functionality" do
    expect(File).to respond_to(:which)
    expect{ File.which(@ruby) }.not_to raise_error
    expect(File.which(@ruby)).to be_kind_of(String)
  end

  example "which accepts an optional path to search" do
    expect{ File.which(@ruby, "/usr/bin:/usr/local/bin") }.not_to raise_error
  end

  example "which returns nil if not found" do
    expect(File.which(@ruby, '/bogus/path')).to be_nil
    expect(File.which('blahblahblah')).to be_nil
  end

  example "which handles executables without extensions on windows" do
    skip "skipped unless MS Windows" unless @windows
    expect(File.which('ruby')).not_to be_nil
    expect(File.which('notepad')).not_to be_nil
  end

  example "which handles executables that already contain extensions on windows" do
    skip "skipped unless MS Windows" unless @windows
    expect(File.which('ruby.exe')).not_to be_nil
    expect(File.which('notepad.exe')).not_to be_nil
  end

  example "which returns argument if an existent absolute path is provided" do
    expect(File.which(@ruby)).to eq(@exe), "May fail on a symlink"
  end

  example "which returns nil if a non-existent absolute path is provided" do
    expect(File.which('/foo/bar/baz/ruby')).to be_nil
  end

  example "which does not pickup files that are not executable" do
    expect(File.which(@non_exe)).to be_nil
  end

  example "which does not pickup executable directories" do
    expect(File.which(@dir)).to be_nil
  end

  example "which accepts a minimum of one argument" do
    expect{ File.which }.to raise_error(ArgumentError)
  end

  example "which accepts a maximum of two arguments" do
    expect{ File.which(@ruby, "foo", "bar") }.to raise_error(ArgumentError)
  end

  example "the second argument cannot be nil or empty" do
    expect{ File.which(@ruby, nil) }.to raise_error(ArgumentError)
    expect{ File.which(@ruby, '') }.to raise_error(ArgumentError)
  end

  example "resolves with with ~" do
    skip "skipped on MS Windows" if @windows
    begin
      old_home = ENV['HOME']

      ENV['HOME'] = Dir::Tmpname.tmpdir
      program = Tempfile.new(['program', '.sh'])
      File.chmod(755, program.path)

      expect(File.which(File.basename(program.path), '~/')).not_to be_nil
    ensure
      ENV['HOME'] = old_home
    end
  end

  after(:context) do
    FileUtils.rm(@non_exe)
    FileUtils.rm_rf(@dir)
  end
end
