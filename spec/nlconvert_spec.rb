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
  let(:dirname)    { File.dirname(__FILE__) }
  let(:test_file1) { File.join(dirname, 'test_nl_convert1.txt') }
  let(:test_file2) { File.join(dirname, 'test_nl_convert2.txt') }

  before do
    File.open(test_file1, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
    File.open(test_file2, 'w'){ |fh| 10.times{ |n| fh.puts "line #{n}" } }
    @test_file1 = File.join(dirname, 'test_nl_convert1.txt')
    @test_file2 = File.join(dirname, 'test_nl_convert2.txt')
    @dos_file   = File.join(dirname, 'dos_test_file.txt')
    @mac_file   = File.join(dirname, 'mac_test_file.txt')
    @unix_file  = 'unix_test_file.txt'
  end

  example "nl_for_platform basic functionality" do
    expect(File).to respond_to(:nl_for_platform)
  end

  example "nl_for_platform returns expected results" do
    expect(File.nl_for_platform('dos') ).to eq( "\cM\cJ")
    expect(File.nl_for_platform('unix') ).to eq( "\cJ")
    expect(File.nl_for_platform('mac') ).to eq( "\cM")

  end

  example "nl_for_platform with 'local' platform does not raise an error" do
    expect{ File.nl_for_platform('local') }.not_to raise_error
  end

  example "nl_for_platform with unsupported platform raises an error" do
    expect{ File.nl_for_platform('bogus') }.to raise_error(ArgumentError)
  end

  example "nl_convert basic functionality" do
    expect(File).to respond_to(:nl_convert)
  end

  example "nl_convert accepts one, two or three arguments" do
    expect{ File.nl_convert(@test_file2) }.not_to raise_error
    expect{ File.nl_convert(@test_file2, @test_file2) }.not_to raise_error
    expect{ File.nl_convert(@test_file2, @test_file2, "unix") }.not_to raise_error
  end

  example "nl_convert with dos platform argument works as expected" do
    expect{ File.nl_convert(@test_file1, @dos_file, "dos") }.not_to raise_error
    expect{ File.nl_convert(@test_file1, @dos_file, "dos") }.not_to raise_error
    expect(File.size(@dos_file)).to be > File.size(@test_file1)
    expect(IO.readlines(@dos_file).first.split("")[-2..-1]).to eq(["\cM","\cJ"])
  end

  example "nl_convert with mac platform argument works as expected" do
    expect{ File.nl_convert(@test_file1, @mac_file, 'mac') }.not_to raise_error
    expect(IO.readlines(@mac_file).first.split("").last).to eq("\cM")

    skip if windows
    expect(File.size(@mac_file)).to eq(File.size(@test_file1))
  end

  example "nl_convert with unix platform argument works as expected" do
    expect{ File.nl_convert(@test_file1, @unix_file, "unix") }.not_to raise_error
    expect(IO.readlines(@unix_file).first.split("").last).to eq("\n")

    if windows
      expect(File.size(@unix_file) >= File.size(@test_file1)).to be true
    else
      expect(File.size(@unix_file) <= File.size(@test_file1)).to be true
    end
  end

  example "nl_convert requires at least one argument" do
    expect{ File.nl_convert }.to raise_error(ArgumentError)
  end

  example "nl_convert requires a valid platform string" do
    expect{ File.nl_convert(@test_file1, "bogus.txt", "blah") }.to raise_error(ArgumentError)
  end

  example "nl_convert accepts a maximum of three arguments" do
    expect{ File.nl_convert(@example_file1, @test_file2, 'dos', 1) }.to raise_error(ArgumentError)
    expect{ File.nl_convert(@test_file1, @test_file2, 'dos', 1) }.to raise_error(ArgumentError)
  end

  example "nl_convert will fail on anything but plain files" do
    expect{ File.nl_convert(IO::NULL, @test_file1) }.to raise_error(ArgumentError)
  end

  after do
    [@dos_file, @mac_file, @unix_file].each{ |file| File.delete(file) if File.exist?(file) }
    File.delete(test_file1) if File.exist?(test_file1)
    File.delete(test_file2) if File.exist?(test_file2)
  end
end
