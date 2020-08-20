#####################################################################
# wc_spec.rb
#
# Specs for the File.wc method. These specs should be run via
# the 'rake wc' task.
#####################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :wc do
  let(:test_file) { 'test_file_wc.txt' }

  before do
    File.open(test_file, 'w'){ |fh| 25.times{ |n| fh.puts "line#{n+1}" } }
  end

  example "wc method basic functionality" do
    expect(File).to respond_to(:wc)
    expect{ File.wc(test_file) }.not_to raise_error
  end

  example "wc accepts specific optional arguments" do
    expect{ File.wc(test_file, 'bytes') }.not_to raise_error
    expect{ File.wc(test_file, 'chars') }.not_to raise_error
    expect{ File.wc(test_file, 'words') }.not_to raise_error
    expect{ File.wc(test_file, 'lines') }.not_to raise_error
  end

  example "argument to wc ignores the case of the option argument" do
    expect{ File.wc(test_file, 'LINES') }.not_to raise_error
  end

  example "wc with no option returns expected results" do
    expect(File.wc(test_file)).to be_kind_of(Array)
    expect(File.wc(test_file)).to eq([166, 166, 25, 25])
  end

  example "wc with bytes option returns the expected result" do
    expect(File.wc(test_file, 'bytes')).to eq(166)
  end

  example "wc with chars option returns the expected result" do
    expect(File.wc(test_file, 'chars')).to eq(166)
  end

  example "wc with words option returns the expected result" do
    expect(File.wc(test_file, 'words')).to eq(25)
  end

  example "wc with lines option returns the expected result" do
    expect(File.wc(test_file, 'lines')).to eq(25)
  end

  example "wc requires at least on argument" do
    expect{ File.wc }.to raise_error(ArgumentError)
  end

  example "an invalid option raises an error" do
    expect{ File.wc(test_file, 'bogus') }.to raise_error(ArgumentError)
  end

  after do
    File.delete(test_file) if File.exists?(test_file)
  end
end
