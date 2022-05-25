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
    @dir = described_class.join(Dir.pwd, 'tempdir')
    @non_exe = described_class.join(Dir.pwd, 'tempfile')
    @ruby = RbConfig::CONFIG['RUBY_INSTALL_NAME']

    Dir.mkdir(@dir) unless described_class.exist?(@dir)
    FileUtils.touch(@non_exe)
    described_class.chmod(775, @dir)
    described_class.chmod(644, @non_exe)

    @exe = described_class.join(
      RbConfig::CONFIG['bindir'],
      RbConfig::CONFIG['ruby_install_name']
    )

    if File::ALT_SEPARATOR
      @exe.tr!('/', '\\')
      @exe << '.exe'
    end
  end

  after(:context) do
    FileUtils.rm(@non_exe)
    FileUtils.rm_rf(@dir)
  end

  example 'which method basic functionality' do
    expect(described_class).to respond_to(:which)
    expect{ described_class.which(@ruby) }.not_to raise_error
    expect(described_class.which(@ruby)).to be_kind_of(String)
  end

  example 'which accepts an optional path to search' do
    expect{ described_class.which(@ruby, '/usr/bin:/usr/local/bin') }.not_to raise_error
  end

  example 'which returns nil if not found' do
    expect(described_class.which(@ruby, '/bogus/path')).to be_nil
    expect(described_class.which('blahblahblah')).to be_nil
  end

  example 'which handles executables without extensions on windows', :windows_only => true do
    expect(described_class.which('ruby')).not_to be_nil
    expect(described_class.which('notepad')).not_to be_nil
  end

  example 'which handles executables that already contain extensions on windows', :windows_only => true do
    expect(described_class.which('ruby.exe')).not_to be_nil
    expect(described_class.which('notepad.exe')).not_to be_nil
  end

  example 'which returns argument if an existent absolute path is provided' do
    expect(described_class.which(@ruby)).to eq(@exe), 'May fail on a symlink'
  end

  example 'which returns nil if a non-existent absolute path is provided' do
    expect(described_class.which('/foo/bar/baz/ruby')).to be_nil
  end

  example 'which does not pickup files that are not executable' do
    expect(described_class.which(@non_exe)).to be_nil
  end

  example 'which does not pickup executable directories' do
    expect(described_class.which(@dir)).to be_nil
  end

  example 'which accepts a minimum of one argument' do
    expect{ described_class.which }.to raise_error(ArgumentError)
  end

  example 'which accepts a maximum of two arguments' do
    expect{ described_class.which(@ruby, 'foo', 'bar') }.to raise_error(ArgumentError)
  end

  example 'the second argument cannot be nil or empty' do
    expect{ described_class.which(@ruby, nil) }.to raise_error(ArgumentError)
    expect{ described_class.which(@ruby, '') }.to raise_error(ArgumentError)
  end

  example 'resolves with with ~', :unix_only => true do
    old_home = ENV['HOME']
    ENV['HOME'] = Dir::Tmpname.tmpdir
    program = Tempfile.new(['program', '.sh'])
    described_class.chmod(755, program.path)

    expect(described_class.which(described_class.basename(program.path), '~/')).not_to be_nil
  ensure
    ENV['HOME'] = old_home
  end
end
