#####################################################################
# test_tail.rb
#
# Test case for the File.tail method. This test should be run via
# the 'rake test_tail' task.
#####################################################################
require 'test-unit'
require 'ptools'

class TC_FileTail < Test::Unit::TestCase
  def self.startup
    Dir.chdir('test') if File.exist?('test')
    File.open('test_file1.txt', 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
  end

  def setup
    @test_file = 'test_file1.txt'

    @expected_tail1 = ["line16","line17","line18","line19"]
    @expected_tail1.push("line20","line21","line22", "line23")
    @expected_tail1.push("line24","line25")

    @expected_tail2 = ["line21","line22","line23","line24","line25"]
  end

  def test_tail_basic
    assert_respond_to(File, :tail)
    assert_nothing_raised{ File.tail(@test_file) }
    assert_nothing_raised{ File.tail(@test_file, 5) }
    assert_nothing_raised{ File.tail(@test_file){} }
  end

  def test_tail_expected_return_values
    assert_kind_of(Array, File.tail(@test_file))
    assert_equal(@expected_tail1, File.tail(@test_file))
    assert_equal(@expected_tail2, File.tail(@test_file, 5))
  end

  def test_tail_expected_errors
    assert_raises(ArgumentError){ File.tail }
    assert_raises(ArgumentError){ File.tail(@test_file, 5, 5) }
  end

  def teardown
    @test_file = nil
    @expected_tail1 = nil
    @expected_tail2 = nil
  end

  def self.shutdown
    File.delete('test_file1.txt') if File.exist?('test_file1.txt')
  end
end
