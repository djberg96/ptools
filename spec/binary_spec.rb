#####################################################################
# test_binary.rb
#
# Test case for the File.binary? method. You should run this test
# via the 'rake test_binary' task.
#####################################################################
require 'rubygems'
require 'rspec'
require 'ptools'

RSpec.describe File, :binary do
  let(:dirname)  { File.dirname(__FILE__) }
  let(:bin_file) { File::ALT_SEPARATOR ? File.join(ENV['windir'], 'notepad.exe') : '/bin/ls' }

  before do
    @txt_file = File.join(dirname, 'txt', 'english.txt')
    @emp_file = File.join(dirname, 'txt', 'empty.txt')
    @uni_file = File.join(dirname, 'txt', 'korean.txt')
    @utf_file = File.join(dirname, 'txt', 'english.utf16')
    @png_file = File.join(dirname, 'img', 'test.png')
    @jpg_file = File.join(dirname, 'img', 'test.jpg')
    @gif_file = File.join(dirname, 'img', 'test.gif')
  end

  example "File.binary? basic functionality" do
    expect(File).to respond_to(:binary?)
    expect{ File.binary?(@txt_file) }.not_to raise_error
  end

  example "File.binary? returns true for binary files" do
    expect(File.binary?(bin_file)).to be true
  end

  example "File.binary? returns false for text files" do
    expect(File.binary?(@emp_file)).to be false
    expect(File.binary?(@txt_file)).to be false
    expect(File.binary?(@uni_file)).to be false
    expect(File.binary?(@utf_file)).to be false
  end

  example "File.binary? returns false for image files" do
    expect(File.binary?(@png_file)).to be false
    expect(File.binary?(@jpg_file)).to be false
    expect(File.binary?(@gif_file)).to be false
  end

  example "File.binary? accepts an optional percentage argument" do
    expect(File.binary?(@txt_file, 0.50)).to be false
    expect(File.binary?(@txt_file, 0.05)).to be true
  end

  example "File.binary? raises an error if the file cannot be found" do
    expect{ File.binary?('bogus') }.to raise_error(SystemCallError)
  end

  example "File.binary? only accepts one argument" do
    expect{ File.binary?(@txt_file, bin_file) }.to raise_error(ArgumentError)
  end
end
