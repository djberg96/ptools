#####################################################################
# test_image.rb
# 
# Test case for the File.image? method. You should run this test
# via the 'rake test_image' task.
#####################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'ptools'

class TC_Ptools_Image < Test::Unit::TestCase
   def self.startup
      Dir.chdir('test') if File.exists?('test')
      File.open('test_file1.txt', 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
   end
   
   def setup   
      @text_file = 'test_file1.txt'
   end

   def test_image_basic
      assert_respond_to(File, :image?)
      assert_nothing_raised{ File.image?(@text_file) }
   end

   def test_image_expected_results
      assert_equal(false, File.image?(@text_file))
   end

   def test_image_expected_errors
      assert_raises(Errno::ENOENT, ArgumentError){ File.image?('bogus') }
   end

   def teardown
      @text_file = nil
   end

   def self.shutdown
      File.delete('test_file1.txt') if File.exists?('test_file1.txt')
   end
end
