#####################################################################
# sparse_spec.rb
#
# Test case for the File.sparse? method. You should run this test
# via the 'rake test:is_sparse' task.
#####################################################################
require 'spec_helper'

RSpec.describe File, :sparse do
  let(:windows) { File::ALT_SEPARATOR }
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

  example 'is_sparse basic functionality', :unix_only => true do
    expect(described_class).to respond_to(:sparse?)
    expect{ described_class.sparse?(sparse_file) }.not_to raise_error
    expect(described_class.sparse?(sparse_file)).to be(true).or be(false)
  end

  example 'is_sparse returns the expected results', :unix_only => true do
    expect(described_class.sparse?(sparse_file)).to be true
    expect(described_class.sparse?(non_sparse_file)).to be false
  end

  example 'is_sparse only accepts one argument' do
    skip if windows
    expect{ described_class.sparse?(sparse_file, sparse_file) }.to raise_error(ArgumentError)
  end
end
