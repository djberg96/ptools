#####################################################################
# test_nlconvert.rb
#
# Test case for the File.nl_convert method. You should run this
# test via the 'rake test_nlconvert' task.
#####################################################################
require 'rubygems'
require 'rspec'
require 'ptools'

RSpec.describe File, :nlconvert do
  let(:windows)    { File::ALT_SEPARATOR }
  let(:dirname)    { described_class.dirname(__FILE__) }
  let(:test_file1) { described_class.join(dirname, 'test_nl_convert1.txt') }
  let(:test_file2) { described_class.join(dirname, 'test_nl_convert2.txt') }

  before do
    described_class.open(test_file1, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
    described_class.open(test_file2, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
    @test_file1 = described_class.join(dirname, 'test_nl_convert1.txt')
    @test_file2 = described_class.join(dirname, 'test_nl_convert2.txt')
    @dos_file   = described_class.join(dirname, 'dos_test_file.txt')
    @mac_file   = described_class.join(dirname, 'mac_test_file.txt')
    @unix_file  = 'unix_test_file.txt'
  end

  after do
    [@dos_file, @mac_file, @unix_file].each{ |file| described_class.delete(file) if described_class.exist?(file) }
    described_class.delete(test_file1) if described_class.exist?(test_file1)
    described_class.delete(test_file2) if described_class.exist?(test_file2)
  end

  example 'nl_for_platform basic functionality' do
    expect(described_class).to respond_to(:nl_for_platform)
  end

  example 'nl_for_platform returns expected results' do
    expect(described_class.nl_for_platform('dos')).to eq("\cM\cJ")
    expect(described_class.nl_for_platform('unix')).to eq("\cJ")
    expect(described_class.nl_for_platform('mac')).to eq("\cM")
  end

  example "nl_for_platform with 'local' platform does not raise an error" do
    expect{ described_class.nl_for_platform('local') }.not_to raise_error
  end

  example 'nl_for_platform with unsupported platform raises an error' do
    expect{ described_class.nl_for_platform('bogus') }.to raise_error(ArgumentError)
  end

  example 'nl_convert basic functionality' do
    expect(described_class).to respond_to(:nl_convert)
  end

  example 'nl_convert accepts one, two or three arguments' do
    expect{ described_class.nl_convert(@test_file2) }.not_to raise_error
    expect{ described_class.nl_convert(@test_file2, @test_file2) }.not_to raise_error
    expect{ described_class.nl_convert(@test_file2, @test_file2, 'unix') }.not_to raise_error
  end

  example 'nl_convert with dos platform argument works as expected' do
    expect{ described_class.nl_convert(@test_file1, @dos_file, 'dos') }.not_to raise_error
    expect{ described_class.nl_convert(@test_file1, @dos_file, 'dos') }.not_to raise_error
    expect(described_class.size(@dos_file)).to be > described_class.size(@test_file1)
    expect(described_class.readlines(@dos_file)).to all(end_with("\cM\cJ"))
  end

  example 'nl_convert with mac platform argument works as expected' do
    expect{ described_class.nl_convert(@test_file1, @mac_file, 'mac') }.not_to raise_error
    expect(described_class.readlines(@mac_file)).to all(end_with("\cM"))

    skip if windows
    expect(described_class.size(@mac_file)).to eq(described_class.size(@test_file1))
  end

  example 'nl_convert with unix platform argument works as expected' do
    expect{ described_class.nl_convert(@test_file1, @unix_file, 'unix') }.not_to raise_error
    expect(described_class.readlines(@unix_file)).to all(end_with("\n"))

    if windows
      expect(described_class.size(@unix_file) >= described_class.size(@test_file1)).to be true
    else
      expect(described_class.size(@unix_file) <= described_class.size(@test_file1)).to be true
    end
  end

  example 'nl_convert requires at least one argument' do
    expect{ described_class.nl_convert }.to raise_error(ArgumentError)
  end

  example 'nl_convert requires a valid platform string' do
    expect{ described_class.nl_convert(@test_file1, 'bogus.txt', 'blah') }.to raise_error(ArgumentError)
  end

  example 'nl_convert accepts a maximum of three arguments' do
    expect{ described_class.nl_convert(@test_file1, @test_file2, 'dos', 1) }.to raise_error(ArgumentError)
  end

  example 'nl_convert will fail on anything but plain files' do
    expect{ described_class.nl_convert(IO::NULL, @test_file1) }.to raise_error(ArgumentError)
  end
end
