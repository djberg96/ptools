#####################################################################
# image_spec.rb
#
# Specs for the File.image? method. You should run these specs via
# the 'rake spec:image' task.
#####################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :image do
  before do
    Dir.chdir('spec') if File.exist?('spec')
    @txt_file  = File.join(Dir.pwd, 'txt', 'english.txt')
    @uni_file  = File.join(Dir.pwd, 'txt', 'korean.txt')
    @jpg_file  = File.join(Dir.pwd, 'img', 'test.jpg')
    @png_file  = File.join(Dir.pwd, 'img', 'test.png')
    @gif_file  = File.join(Dir.pwd, 'img', 'test.gif')
    @ico_file  = File.join(Dir.pwd, 'img', 'test.ico')
  end

  example "image? method basic functionality" do
    expect(File).to respond_to(:image?)
    expect{ File.image?(@txt_file) }.not_to raise_error
    expect(File.image?(@txt_file)).to be(true).or be(false)
  end

  example "image? method returns false for a text file" do
    expect(File.image?(@txt_file)).to be false
    expect(File.image?(@uni_file)).to be false
  end

  example "image? method returns true for a gif" do
    expect(File.image?(@gif_file)).to be true
  end

  example "image? method returns true for a jpeg" do
    expect(File.image?(@jpg_file)).to be true
  end

  example "image? method returns true for a png" do
    expect(File.image?(@png_file)).to be true
  end

  example "image? method returns true for an ico" do
    expect(File.image?(@ico_file)).to be true
  end

  example "image? method raises an error if the file does not exist" do
    expect{ File.image?('bogus') }.to raise_error(Exception) # Errno::ENOENT or ArgumentError
  end
end
