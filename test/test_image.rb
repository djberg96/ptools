#####################################################################
# test_image.rb
#
# Test case for the File.image? method. You should run this test
# via the 'rake test:image' task.
#####################################################################
require 'test-unit'
require 'ptools'

class TC_Ptools_Image < Test::Unit::TestCase
  def self.startup
    Dir.chdir('test') if File.exist?('test')
    File.open('test_file1.txt', 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
  end

  def setup
    @text_file = 'test_file1.txt'
    @jpg_file  = File.join(Dir.pwd, 'img', 'test.jpg')
    @png_file  = File.join(Dir.pwd, 'img', 'test.png')
    @gif_file  = File.join(Dir.pwd, 'img', 'test.gif')
  end

  test "image? method basic functionality" do
    assert_respond_to(File, :image?)
    assert_nothing_raised{ File.image?(@text_file) }
    assert_boolean(File.image?(@text_file))
  end

  test "image? method returns false for a text file" do
    assert_false(File.image?(@text_file))
  end

  test "image? method returns true for a gif" do
    assert_true(File.image?(@gif_file))
  end

  test "image? method returns true for a jpeg" do
    assert_true(File.image?(@jpg_file))
  end

  test "image? method returns true for a png" do
    assert_true(File.image?(@png_file))
  end

  test "image? method raises an error if the file does not exist" do
    assert_raises(Errno::ENOENT, ArgumentError){ File.image?('bogus') }
  end

  def teardown
    @text_file = nil
  end

  def self.shutdown
    File.delete('test_file1.txt') if File.exist?('test_file1.txt')
    @jpeg_file = nil
    @png_file  = nil
    @gif_file  = nil
  end
end
