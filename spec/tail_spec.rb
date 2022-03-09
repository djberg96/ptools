#####################################################################
# tail_spec.rb
#
# Tests for the File.tail method. This test should be run via
# the 'rake spec:tail' task.
#####################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :tail do
  let(:dirname)            { described_class.dirname(__FILE__) }
  let(:test_file1)         { described_class.join(dirname, 'test_file1.txt') }
  let(:test_file64)        { described_class.join(dirname, 'test_file64.txt') }
  let(:test_file128)       { described_class.join(dirname, 'test_file128.txt') }
  let(:test_file_trail)    { described_class.join(dirname, 'test_file_trail.txt') }
  let(:test_file_trail_nl) { described_class.join(dirname, 'test_file_trail_nl.txt') }

  before do
    described_class.open(test_file1, 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }

    # Trailing newline test
    described_class.open(test_file_trail, 'w') do |fh|
      2.times{ |n| fh.puts "trail#{n+1}" }
      fh.write 'trail3'
    end

    described_class.open(test_file_trail_nl, 'w') do |fh|
      3.times{ |n| fh.puts "trail#{n+1}" }
    end

    # Larger files
    test_tail_fmt_str = 'line data data data data data data data %5s'

    described_class.open(test_file64, 'w') do |fh|
      2000.times do |n|
        fh.puts test_tail_fmt_str % (n+1).to_s
      end
    end

    described_class.open(test_file128, 'w') do |fh|
      4500.times do |n|
        fh.puts test_tail_fmt_str % (n+1).to_s
      end
    end

    @expected_tail1 = %w[
      line16 line17 line18 line19 line20
      line21 line22 line23 line24 line25
    ]

    @expected_tail2 = %w[line21 line22 line23 line24 line25]

    @expected_tail_more = []
    25.times{ |n| @expected_tail_more.push "line#{n+1}" }

    @expected_tail_trail = %w[trail2 trail3]

    @test_tail_fmt_str = 'line data data data data data data data %5s'
  end

  after do
    described_class.delete(test_file1) if described_class.exist?(test_file1)
    described_class.delete(test_file64) if described_class.exist?(test_file64)
    described_class.delete(test_file128) if described_class.exist?(test_file128)
    described_class.delete(test_file_trail_nl) if described_class.exist?(test_file_trail_nl)
    described_class.delete(test_file_trail) if described_class.exist?(test_file_trail)
  end

  example 'tail basic functionality' do
    expect(described_class).to respond_to(:tail)
    expect{ described_class.tail(test_file1) }.not_to raise_error
    expect{ described_class.tail(test_file1, 5) }.not_to raise_error
    expect{ described_class.tail(test_file1){} }.not_to raise_error
  end

  example 'tail returns the expected values' do
    expect(described_class.tail(test_file1)).to be_kind_of(Array)
    expect(described_class.tail(test_file1)).to eq(@expected_tail1)
    expect(described_class.tail(test_file1, 5)).to eq(@expected_tail2)
  end

  example 'specifying a number greater than the actual number of lines works as expected' do
    expect(described_class.tail(test_file1, 30)).to eq(@expected_tail_more)
  end

  example 'tail requires two arguments' do
    expect{ described_class.tail }.to raise_error(ArgumentError)
    expect{ described_class.tail(test_file1, 5, 5) }.to raise_error(ArgumentError)
  end

  example 'tail works as expected when there is no trailing newline' do
    expect(described_class.tail(test_file_trail, 2)).to eq(@expected_tail_trail)
    expect(described_class.tail(test_file_trail_nl, 2)).to eq(@expected_tail_trail)
  end

  example 'tail works as expected on a file larger than 64k' do
    expected_tail_64k = []
    2000.times{ |n| expected_tail_64k.push(@test_tail_fmt_str % (n+1).to_s) }
    expect(described_class.tail(test_file64, 2000)).to eq(expected_tail_64k)
  end

  example 'tail works as expected on a file larger than 128k' do
    expected_tail_128k = []
    4500.times{ |n| expected_tail_128k.push(@test_tail_fmt_str % (n+1).to_s) }
    expect(described_class.tail(test_file128, 4500)).to eq(expected_tail_128k)
  end
end
