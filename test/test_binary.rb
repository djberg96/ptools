#####################################################################
# test_binary.rb
#
# Test case for the File.binary? method. You should run this test
# via the 'rake test_binary' task.
#####################################################################
require 'rubygems'
require 'test-unit'
require 'ptools'

class TC_Ptools_Binary < Test::Unit::TestCase
  def self.startup
    @@txt_file = 'test_binary.txt'

    if File::ALT_SEPARATOR
      @@bin_file = File.join(ENV['windir'], 'notepad.exe')
    else
      @@bin_file = '/bin/ls'
    end

    Dir.chdir('test') if File.exists?('test')

    File.open(@@txt_file, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
  end

  test "File.binary? basic functionality" do
    assert_respond_to(File, :binary?)
    assert_nothing_raised{ File.binary?(@@txt_file) }
  end

  test "File.binary? returns expected results" do
    assert_false(File.binary?(@@txt_file))
    assert_true(File.binary?(@@bin_file))
  end

  test "File.binary? raises an error if the file cannot be found" do
    assert_raise_kind_of(SystemCallError){ File.binary?('bogus') }
  end

  test "File.binary? only accepts one argument" do
    assert_raise_kind_of(ArgumentError){ File.binary?(@@txt_file, @@bin_file) }
  end

  def self.shutdown
    File.delete(@@txt_file) if File.exists?(@@txt_file)
  end
end
