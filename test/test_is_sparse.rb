#####################################################################
# test_is_sparse.rb
#
# Test case for the File.sparse? method. You should run this test
# via the 'rake test:is_sparse' task.
#####################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'ptools'

class TC_IsSparse < Test::Unit::TestCase
  def self.startup
    Dir.chdir("test") if File.exists?("test")
    @@win = RbConfig::CONFIG['host_os'] =~ /windows|mswin|dos|cygwin|mingw/i
    @@osx = RbConfig::CONFIG['host_os'] =~ /darwin|osx/i
    @@sun = RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
  end

  def setup
    @sparse_file = @@sun ? '/var/adm/lastlog' : '/var/log/lastlog'
    @non_sparse_file = File.expand_path(File.basename(__FILE__))
  end

  test "is_sparse basic functionality" do
    omit_if(@@win, "File.sparse? tests skipped on MS Windows")
    omit_if(@@osx, "File.sparse? tests skipped on OS X")

    assert_respond_to(File, :sparse?)
    assert_nothing_raised{ File.sparse?(@sparse_file) }
    assert_boolean(File.sparse?(@sparse_file))
  end

  test "is_sparse returns the expected results" do
    omit_if(@@win, "File.sparse? tests skipped on MS Windows")
    omit_if(@@osx, "File.sparse? tests skipped on OS X")

    assert_true(File.sparse?(@sparse_file))
    assert_false(File.sparse?(@non_sparse_file))
  end

  test "is_sparse only accepts one argument" do
    omit_if(@@win, "File.sparse? tests skipped on MS Windows")
    assert_raise(ArgumentError){ File.sparse?(@sparse_file, @sparse_file) }
  end

  def teardown
    @sparse_file = nil
    @non_sparse_file = nil
  end
end
