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
    if File::ALT_SEPARATOR
      @@bin_file = File.join(ENV['windir'], 'notepad.exe')
    else
      @@bin_file = '/bin/ls'
    end

    Dir.chdir('test') if File.exist?('test')
  end

  def setup
    @txt_file = File.join('txt', 'english.txt')
    @uni_file = File.join('txt', 'korean.txt')
    @png_file = File.join('img', 'test.png')
    @jpg_file = File.join('img', 'test.jpg')
    @gif_file = File.join('img', 'test.gif')
  end

  test "File.binary? basic functionality" do
    assert_respond_to(File, :binary?)
    assert_nothing_raised{ File.binary?(@txt_file) }
  end

  test "File.binary? returns true for binary files" do
    assert_true(File.binary?(@@bin_file))
  end

  test "File.binary? returns false for text files" do
    assert_false(File.binary?(@txt_file))
    assert_false(File.binary?(@uni_file))
  end

  test "File.binary? returns false for image files" do
    assert_false(File.binary?(@png_file))
    assert_false(File.binary?(@jpg_file))
    assert_false(File.binary?(@gif_file))
  end

  test "File.binary? raises an error if the file cannot be found" do
    assert_raise_kind_of(SystemCallError){ File.binary?('bogus') }
  end

  test "File.binary? only accepts one argument" do
    assert_raise_kind_of(ArgumentError){ File.binary?(@txt_file, @@bin_file) }
  end

  def teardown
    @txt_file = nil
    @uni_file = nil
    @png_file = nil
    @jpg_file = nil
    @gif_file = nil
  end
end
