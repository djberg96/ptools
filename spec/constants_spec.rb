##############################################################################
# constants_spec.rb
#
# Specs for the constants that have been defined in the ptools library.
# This test case should be run via the 'rake spec:constants' task.
##############################################################################
require 'rubygems'
require 'rspec'
require 'rbconfig'
require 'ptools'

RSpec.describe File, :constants do
  let(:windows) { File::ALT_SEPARATOR }

  example "PTOOLS_VERSION constant is set to expected value" do
    expect(File::PTOOLS_VERSION).to eq('1.4.0')
    expect(File::PTOOLS_VERSION.frozen?).to be true
  end

  example "IMAGE_EXT constant is set to array of values" do
    expect(File::IMAGE_EXT.sort).to eq(%w[.bmp .gif .jpeg .jpg .png])
  end

  example "WINDOWS constant is defined on MS Windows" do
    skip "skipped unless MS Windows" unless windows
    expect(File::MSWINDOWS).not_to be_nil
  end

  example "WIN32EXTS constant is defined on MS Windows" do
    skip "skipped unless MS Windows" unless windows
    expect(File::WIN32EXTS).not_to be_nil
  end
end
