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
    Dir.chdir('spec') if described_class.exist?('spec')
    @txt_file  = described_class.join(Dir.pwd, 'txt', 'english.txt')
    @uni_file  = described_class.join(Dir.pwd, 'txt', 'korean.txt')
    @jpg_file  = described_class.join(Dir.pwd, 'img', 'test.jpg')
    @png_file  = described_class.join(Dir.pwd, 'img', 'test.png')
    @gif_file  = described_class.join(Dir.pwd, 'img', 'test.gif')
    @ico_file  = described_class.join(Dir.pwd, 'img', 'test.ico')
    @no_ext    = described_class.join(Dir.pwd, 'img', 'jpg_no_ext')
  end

  example 'image? method basic functionality' do
    expect(described_class).to respond_to(:image?)
    expect{ described_class.image?(@txt_file) }.not_to raise_error
    expect(described_class.image?(@txt_file)).to be(true).or be(false)
  end

  example 'image? method returns false for a text file' do
    expect(described_class.image?(@txt_file)).to be false
    expect(described_class.image?(@uni_file)).to be false
  end

  example 'image? method returns true for a gif' do
    expect(described_class.image?(@gif_file)).to be true
    expect(described_class.image?(@gif_file, check_file_extension: false)).to be true
  end

  example 'image? method returns true for a jpeg' do
    expect(described_class.image?(@jpg_file)).to be true
    expect(described_class.image?(@jpg_file, check_file_extension: false)).to be true
  end

  example 'image? method returns true for a png' do
    expect(described_class.image?(@png_file)).to be true
    expect(described_class.image?(@png_file, check_file_extension: false)).to be true
  end

  example 'image? method returns true for an ico' do
    expect(described_class.image?(@ico_file)).to be true
    expect(described_class.image?(@ico_file, check_file_extension: false)).to be true
  end

  example 'image? method raises an error if the file does not exist' do
    expect{ described_class.image?('bogus') }.to raise_error(Exception) # Errno::ENOENT or ArgumentError
  end

  example "image? returns appropriate value if the extension isn't included" do
    expect(described_class.image?(@no_ext, check_file_extension: true)).to be false
    expect(described_class.image?(@no_ext, check_file_extension: false)).to be true
  end
end
