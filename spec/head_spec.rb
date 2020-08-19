######################################################################
# head_spec.rb
#
# Specs for the File.head method. These specs should be run via
# the 'rake spec:head' task.
######################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :head do
  let(:test_file) { 'test_file_head.txt' }

  before do
    File.open(test_file, 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
    @expected_head1 = ["line1\n","line2\n","line3\n","line4\n","line5\n"]
    @expected_head1.push("line6\n","line7\n","line8\n","line9\n","line10\n")
    @expected_head2 = ["line1\n","line2\n","line3\n","line4\n","line5\n"]
  end

  example "head method basic functionality" do
    expect(File).to respond_to(:head)
    expect{ File.head(test_file) }.not_to raise_error
    expect{ File.head(test_file, 5) }.not_to raise_error
    expect{ File.head(test_file){} }.not_to raise_error
  end

  example "head method returns the expected results" do
    expect(File.head(test_file)).to be_kind_of(Array)
    expect(File.head(test_file)).to eq(@expected_head1)
    expect(File.head(test_file, 5)).to eq(@expected_head2)
  end

  example "head method requires two arguments" do
    expect{ File.head(test_file, 5, "foo") }.to raise_error(ArgumentError)
    expect{ File.head("bogus") }.to raise_error(Errno::ENOENT)
  end

  after do
    File.delete(test_file) if File.exists?(test_file)
  end
end
