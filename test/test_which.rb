#####################################################################
# test_which.rb
#
# Test case for the File.which method. You should run this test
# via the 'rake test_which' rake task.
#
# NOTE: I make the assumption that Ruby (or JRuby) is in your
# PATH for these tests.
#####################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'rbconfig'
require 'ptools'
include Config

class TC_FileWhich < Test::Unit::TestCase
  def self.startup
    @@windows = Config::CONFIG['host_os'] =~ /mswin|msdos|win32|cygwin|mingw/i
  end

  def setup
    @ruby = RUBY_PLATFORM.match('java') ? 'jruby' : 'ruby'
    @exe = File.join(CONFIG['bindir'], CONFIG['ruby_install_name']) 

    if @@windows
      @exe.tr!('/','\\')
      @exe << ".exe"
    end
  end

  test "which basic functionality" do
    assert_respond_to(File, :which)
    assert_nothing_raised{ File.which(@ruby) }
    assert_kind_of(String, File.which(@ruby))
  end

  test "which accepts an optional path to search" do
    assert_nothing_raised{ File.which(@ruby, "/usr/bin:/usr/local/bin") }
  end

  test "which returns nil if not found" do
    assert_equal(nil, File.which(@ruby, '/bogus/path'))
    assert_equal(nil, File.which('blahblahblah'))
  end

  test "which handles executables without extensions on windows" do
    omit_unless(@@windows, "test skipped on MS Windows")
    assert_not_nil(File.which('ruby'))
    assert_not_nil(File.which('notepad'))
  end

  test "which handles executables that already contain extensions on windows" do
    omit_unless(@@windows, "test skipped on MS Windows")
    assert_not_nil(File.which('ruby.exe'))
    assert_not_nil(File.which('notepad.exe'))
  end

  test "which returns argument if an existent absolute path is provided" do
    assert_equal(@exe, File.which(@ruby))
  end

  test "which returns nil if a non-existent absolute path is provided" do
    assert_equal(nil, File.which('/foo/bar/baz/ruby'))
  end

  test "which accepts a minimum of one argument" do
    assert_raises(ArgumentError){ File.which }
  end

  test "which accepts a maximum of two arguments" do
    assert_raises(ArgumentError){ File.which(@ruby, "foo", "bar") }
  end

  test "the second argument cannot be nil" do
    assert_raises(ArgumentError){ File.which(@ruby, nil) }
  end

  def teardown
    @exe  = nil
    @ruby = nil
  end

  def self.shutdown
    @@windows = nil
  end
end
