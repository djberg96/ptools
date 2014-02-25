#####################################################################
# test_image.rb
#
# Test case for the File.image? method. You should run this test
# via the 'rake test_image' task.
#####################################################################
require 'test-unit'
require 'ptools'

class TC_Ptools_Image < Test::Unit::TestCase
  def self.startup
    Dir.chdir('test') if File.exist?('test')
    File.open('test_file1.txt', 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
    File.open('test_png_file.txt', 'w:UTF-8'){ |fh| fh.puts "\x89PNG-anything-after-the-prefix" }
  end

  def setup
    @text_file = 'test_file1.txt'
    @png_file = 'test_png_file.txt'
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
  
  def test_image_is_true_for_fake_png_file
    assert_equal(true, File.image?(@png_file))
  end

  def teardown
    @text_file = nil
  end

  def self.shutdown
    File.delete('test_file1.txt') if File.exist?('test_file1.txt')
    File.delete('test_png_file.txt') if File.exist?('test_png_file.txt')
  end
end
