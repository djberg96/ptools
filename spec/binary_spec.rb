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
  let(:dirname)  { described_class.dirname(__FILE__) }
  let(:bin_file) { File::ALT_SEPARATOR ? described_class.join(ENV['windir'], 'notepad.exe') : '/bin/ls' }

  before do
    @txt_file = described_class.join(dirname, 'txt', 'english.txt')
    @emp_file = described_class.join(dirname, 'txt', 'empty.txt')
    @uni_file = described_class.join(dirname, 'txt', 'korean.txt')
    @utf_file = described_class.join(dirname, 'txt', 'english.utf16')
    @png_file = described_class.join(dirname, 'img', 'test.png')
    @jpg_file = described_class.join(dirname, 'img', 'test.jpg')
    @gif_file = described_class.join(dirname, 'img', 'test.gif')
  end

  example 'File.binary? basic functionality' do
    expect(described_class).to respond_to(:binary?)
    expect{ described_class.binary?(@txt_file) }.not_to raise_error
  end

  example 'File.binary? returns true for binary files' do
    expect(described_class.binary?(bin_file)).to be true
  end

  example 'File.binary? returns true for unix binary files', :unix_only => true do
    expect(described_class.binary?('/bin/df')).to be true
    expect(described_class.binary?('/bin/chmod')).to be true
    expect(described_class.binary?('/bin/cat')).to be true
  end

  example 'File.binary? returns false for text files' do
    expect(described_class.binary?(@emp_file)).to be false
    expect(described_class.binary?(@txt_file)).to be false
    expect(described_class.binary?(@uni_file)).to be false
    expect(described_class.binary?(@utf_file)).to be false
  end

  example 'File.binary? returns false for image files' do
    expect(described_class.binary?(@png_file)).to be false
    expect(described_class.binary?(@jpg_file)).to be false
    expect(described_class.binary?(@gif_file)).to be false
  end

  example 'File.binary? raises an error if the file cannot be found' do
    expect{ described_class.binary?('bogus') }.to raise_error(SystemCallError)
  end

  example 'File.binary? only accepts one argument' do
    expect{ described_class.binary?(@txt_file, bin_file) }.to raise_error(ArgumentError)
  end
end
