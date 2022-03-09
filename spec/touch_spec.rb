#####################################################################
# test_touch.rb
#
# Test case for the File.touch method. This test should be run
# via the 'rake test_touch task'.
#####################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :touch do
  let(:dirname) { described_class.dirname(__FILE__) }
  let(:filename) { 'test_file_touch.txt' }
  let(:xfile) { described_class.join(dirname, filename) }

  before do
    described_class.open(xfile, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
    @test_file = described_class.join(dirname, 'delete.this')
  end

  after do
    described_class.delete(@test_file) if described_class.exist?(@test_file)
    described_class.delete(xfile) if described_class.exist?(xfile)
  end

  example 'touch basic functionality' do
    expect(described_class).to respond_to(:touch)
    expect{ described_class.touch(@test_file) }.not_to raise_error
  end

  example 'touch a new file returns expected results' do
    expect(described_class.touch(@test_file)).to eq(described_class)
    expect(described_class.exist?(@test_file)).to be true
    expect(described_class.size(@test_file)).to eq(0)
  end

  example 'touch an existing file returns expected results' do
    stat = described_class.stat(xfile)
    sleep 1
    expect{ described_class.touch(xfile) }.not_to raise_error
    expect(described_class.size(xfile) == stat.size).to be true
    expect(described_class.mtime(xfile) == stat.mtime).to be false
  end

  example 'touch requires an argument' do
    expect{ described_class.touch }.to raise_error(ArgumentError)
  end
end
