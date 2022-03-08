#####################################################################
# test_is_sparse.rb
#
# Test case for the File.sparse? method. You should run this test
# via the 'rake test:is_sparse' task.
#####################################################################
require 'rspec'
require 'ptools'

RSpec.describe File, :sparse do
  let(:windows) { File::ALT_SEPARATOR }
  let(:osx) { RbConfig::CONFIG['host_os'] =~ /darwin|osx/i }
  let(:non_sparse_file) { described_class.expand_path(described_class.basename(__FILE__)) }
  let(:sparse_file) { 'test_sparse_file' }

  before do
    Dir.chdir('spec') if described_class.exist?('spec')
    system("dd of=#{sparse_file} bs=1k seek=5120 count=0 2>/dev/null") unless windows
  end

  after do
    Dir.chdir('spec') if described_class.exist?('spec')
    described_class.delete(sparse_file) if described_class.exist?(sparse_file)
  end

  example 'is_sparse basic functionality' do
    skip 'skipped on MS Windows or OSX' if windows || osx
    expect(described_class).to respond_to(:sparse?)
    expect{ described_class.sparse?(sparse_file) }.not_to raise_error
    expect(described_class.sparse?(sparse_file)).to be(true).or be(false)
  end

  example 'is_sparse returns the expected results' do
    skip 'skipped on MS Windows or OSX' if windows || osx
    expect(described_class.sparse?(sparse_file)).to be true
    expect(described_class.sparse?(non_sparse_file)).to be false
  end

  example 'is_sparse only accepts one argument' do
    skip if windows
    expect{ described_class.sparse?(sparse_file, sparse_file) }.to raise_error(ArgumentError)
  end
end
