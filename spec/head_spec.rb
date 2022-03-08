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
    described_class.open(test_file, 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
    @expected_head1 = %W[line1\n line2\n line3\n line4\n line5\n]
    @expected_head1.push("line6\n", "line7\n", "line8\n", "line9\n", "line10\n")
    @expected_head2 = %W[line1\n line2\n line3\n line4\n line5\n]
  end

  after do
    described_class.delete(test_file) if described_class.exist?(test_file)
  end

  example 'head method basic functionality' do
    expect(described_class).to respond_to(:head)
    expect{ described_class.head(test_file) }.not_to raise_error
    expect{ described_class.head(test_file, 5) }.not_to raise_error
    expect{ described_class.head(test_file){} }.not_to raise_error
  end

  example 'head method returns the expected results' do
    expect(described_class.head(test_file)).to be_kind_of(Array)
    expect(described_class.head(test_file)).to eq(@expected_head1)
    expect(described_class.head(test_file, 5)).to eq(@expected_head2)
  end

  example 'head method requires two arguments' do
    expect{ described_class.head(test_file, 5, 'foo') }.to raise_error(ArgumentError)
    expect{ described_class.head('bogus') }.to raise_error(Errno::ENOENT)
  end
end
