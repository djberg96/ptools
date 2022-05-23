######################################################################
# test_whereis.rb
#
# Tests for the File.whereis method.
######################################################################
require 'rubygems'
require 'rspec'
require 'ptools'
require 'rbconfig'

RSpec.describe File, :whereis do
  let(:windows) { File::ALT_SEPARATOR }
  let(:ruby) { RUBY_ENGINE }
  let(:bin_dir) { RbConfig::CONFIG['bindir'] }

  before do
    @expected_locs = [described_class.join(bin_dir, ruby)]

    if windows
      @expected_locs[0] << '.exe'
      @expected_locs[0].tr!('/', '\\')
    end

    unless windows
      @expected_locs << "/usr/local/bin/#{ruby}"
      @expected_locs << "/opt/sfw/bin/#{ruby}"
      @expected_locs << "/opt/bin/#{ruby}"
      @expected_locs << "/usr/bin/#{ruby}"
    end

    @actual_locs = nil
  end

  example 'whereis basic functionality' do
    expect(described_class).to respond_to(:whereis)
    expect{ described_class.whereis('ruby') }.not_to raise_error
    expect(described_class.whereis('ruby')).to be_kind_of(Array).or be_nil
  end

  example 'whereis accepts an optional second argument' do
    expect{ described_class.whereis('ruby', '/usr/bin:/usr/local/bin') }.not_to raise_error
  end

  example 'whereis returns expected values' do
    expect{ @actual_locs = described_class.whereis(ruby) }.not_to raise_error
    expect(@actual_locs).to be_kind_of(Array)
    expect((@expected_locs & @actual_locs).size > 0).to be true
  end

  example 'whereis returns nil if program not found' do
    expect(described_class.whereis('xxxyyy')).to be_nil
  end

  example 'whereis returns nil if program cannot be found in provided path' do
    expect(described_class.whereis(ruby, '/foo/bar')).to be_nil
  end

  example 'whereis returns single element array or nil if absolute path is provided' do
    absolute = described_class.join(bin_dir, ruby)
    absolute << '.exe' if windows

    expect(described_class.whereis(absolute)).to eq([absolute])
    expect(described_class.whereis("/foo/bar/baz/#{ruby}")).to be_nil
  end

  example 'whereis works with an explicit extension on ms windows', :windows_only => true do
    expect(described_class.whereis("#{ruby}.exe")).not_to be_nil
  end

  example 'whereis requires at least one argument' do
    expect{ described_class.whereis }.to raise_error(ArgumentError)
  end

  example 'whereis returns unique paths only' do
    expect(described_class.whereis(ruby) == described_class.whereis(ruby).uniq).to be true
  end

  example 'whereis accepts a maximum of two arguments' do
    expect{ described_class.whereis(ruby, 'foo', 'bar') }.to raise_error(ArgumentError)
  end

  example 'the second argument to whereis cannot be nil or empty' do
    expect{ described_class.whereis(ruby, nil) }.to raise_error(ArgumentError)
    expect{ described_class.whereis(ruby, '') }.to raise_error(ArgumentError)
  end
end
