#####################################################################
# tc_binary.rb
# 
# Test case for the File.binary? method. You should run this test
# via the 'rake test_binary' task.
#####################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'ptools'

class TC_Binary < Test::Unit::TestCase
   def self.startup
      Dir.chdir('test') if File.exists?('test')
      File.open('test_file1.txt', 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
   end
   
   def setup
      @text_file = 'test_file1.txt'
   end

   def test_binary_basic
      assert_respond_to(File, :binary?)
      assert_nothing_raised{ File.binary?(@text_file) }
   end

   def test_binary_expected_results
      assert_equal(false, File.binary?(@text_file))
   end

   def test_binary_expected_errors
      assert_raise_kind_of(SystemCallError){ File.binary?('bogus') }
   end

   def teardown
      @text_file = nil
   end

   def self.shutdown
      File.delete('test_file1.txt') if File.exists?('test_file1.txt')
   end
end
