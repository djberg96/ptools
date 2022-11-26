#####################################################################
# image_spec.rb
#
# Specs for various image methods as well as the File.image? method
# itself. You should run these specs via the 'rake spec:image' task.
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
    @tif_file  = described_class.join(Dir.pwd, 'img', 'test.tiff')
    @ico_file  = described_class.join(Dir.pwd, 'img', 'test.ico')
    @no_ext    = described_class.join(Dir.pwd, 'img', 'jpg_no_ext')
    @bmp_file  = described_class.join(Dir.pwd, 'img', 'test.bmp')
  end

  context 'bmp?' do
    example 'bmp? method basic functionality' do
      described_class.bmp?(@bmp_file)
      expect(described_class).to respond_to(:bmp?)
      expect{ described_class.bmp?(@bmp_file) }.not_to raise_error
      expect(described_class.bmp?(@bmp_file)).to be(true).or be(false)
    end

    example 'bmp? method returns true for a bitmap file' do
      expect(described_class.bmp?(@bmp_file)).to be(true)
    end

    example 'bmp? method returns false for an image that is not a bitmap' do
      expect(described_class.bmp?(@gif_file)).to be(false)
      expect(described_class.bmp?(@tif_file)).to be(false)
    end

    example 'bmp? method returns false for a text file' do
      expect(described_class.bmp?(@txt_file)).to be(false)
    end
  end

  context 'gif?' do
    example 'gif? method basic functionality' do
      expect(described_class).to respond_to(:gif?)
      expect{ described_class.gif?(@gif_file) }.not_to raise_error
      expect(described_class.gif?(@gif_file)).to be(true).or be(false)
    end

    example 'gif? method returns true for a gif file' do
      expect(described_class.gif?(@gif_file)).to be(true)
    end

    example 'gif? method returns false for an image that is not a gif' do
      expect(described_class.gif?(@jpg_file)).to be(false)
    end

    example 'gif? method returns false for a text file' do
      expect(described_class.gif?(@txt_file)).to be(false)
    end
  end

  context 'ico?' do
    example 'ico? method basic functionality' do
      expect(described_class).to respond_to(:ico?)
      expect{ described_class.ico?(@ico_file) }.not_to raise_error
      expect(described_class.ico?(@ico_file)).to be(true).or be(false)
    end

    example 'ico? method returns true for an icon file' do
      expect(described_class.ico?(@ico_file)).to be(true)
    end

    example 'ico? method returns false for an image that is not a icon file' do
      expect(described_class.ico?(@gif_file)).to be(false)
      expect(described_class.ico?(@png_file)).to be(false)
    end

    example 'ico? method returns false for a text file' do
      expect(described_class.ico?(@txt_file)).to be(false)
    end
  end

  context 'image?' do
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

  context 'jpg?' do
    example 'jpg? method basic functionality' do
      expect(described_class).to respond_to(:jpg?)
      expect{ described_class.jpg?(@jpg_file) }.not_to raise_error
      expect(described_class.jpg?(@jpg_file)).to be(true).or be(false)
    end

    example 'jpg? method returns true for a jpeg file' do
      expect(described_class.jpg?(@jpg_file)).to be(true)
    end

    example 'jpg? method returns false for an image that is not a jpeg' do
      expect(described_class.jpg?(@gif_file)).to be(false)
    end

    example 'jpg? method returns false for a text file' do
      expect(described_class.jpg?(@txt_file)).to be(false)
    end
  end

  context 'png?' do
    example 'png? method basic functionality' do
      expect(described_class).to respond_to(:png?)
      expect{ described_class.png?(@png_file) }.not_to raise_error
      expect(described_class.png?(@png_file)).to be(true).or be(false)
    end

    example 'png? method returns true for a png file' do
      expect(described_class.png?(@png_file)).to be(true)
    end

    example 'png? method returns false for an image that is not a png' do
      expect(described_class.png?(@gif_file)).to be(false)
    end

    example 'png? method returns false for a text file' do
      expect(described_class.png?(@txt_file)).to be(false)
    end
  end

  context 'tiff?' do
    example 'tiff? method basic functionality' do
      expect(described_class).to respond_to(:tiff?)
      expect{ described_class.tiff?(@tif_file) }.not_to raise_error
      expect(described_class.tiff?(@tif_file)).to be(true).or be(false)
    end

    example 'tiff? method returns true for a tiff file' do
      expect(described_class.tiff?(@tif_file)).to be(true)
    end

    example 'tiff? method returns false for an image that is not a tiff' do
      expect(described_class.tiff?(@jpg_file)).to be(false)
    end

    example 'tiff? method returns false for a text file' do
      expect(described_class.tiff?(@txt_file)).to be(false)
    end
  end
end
