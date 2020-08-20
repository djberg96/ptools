#####################################################################
# test_touch.rb
#
# Test case for the File.touch method. This test should be run
# via the 'rake test_touch task'.
#####################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :touch do
  let(:dirname) { File.dirname(__FILE__) }
  let(:filename) { 'test_file_touch.txt' }
  let(:xfile) { File.join(dirname, filename) }

  before do
    File.open(xfile, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
    @test_file = File.join(dirname, 'delete.this')
  end

  example "touch basic functionality" do
    expect(File).to respond_to(:touch)
    expect{ File.touch(@test_file) }.not_to raise_error
  end

  example "touch a new file returns expected results" do
    expect(File.touch(@test_file)).to eq(File)
    expect(File.exist?(@test_file)).to be true
    expect(File.size(@test_file)).to eq(0)
  end

  example "touch an existing file returns expected results" do
    stat = File.stat(xfile)
    sleep 0.5
    expect{ File.touch(xfile) }.not_to raise_error
    expect(File.size(xfile) == stat.size).to be true
    expect(File.mtime(xfile) == stat.mtime).to be false
  end

  example "touch requires an argument" do
    expect{ File.touch }.to raise_error(ArgumentError)
  end

  after do
    File.delete(@test_file) if File.exist?(@test_file)
    File.delete(xfile) if File.exist?(xfile)
  end
end
