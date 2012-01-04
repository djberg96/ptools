#####################################################################
# test_constants.rb
#
# Tests the constants that have been defined for our package. This
# test case should be run via the 'rake test_constants' task.
#####################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'rbconfig'
require 'ptools'

class TC_Constants < Test::Unit::TestCase
  def self.startup
    @@windows = File::ALT_SEPARATOR
  end

  def test_version
    assert_equal('1.2.2', File::PTOOLS_VERSION)
  end

  def test_image_ext
    assert_equal(%w/.bmp .gif .jpeg .jpg .png/, File::IMAGE_EXT.sort)
  end

  def test_windows
    omit_unless(@@windows, "Skipping on Unix systems")
    assert_not_nil(File::IS_WINDOWS)
  end

  def test_win32exts
    omit_unless(@@windows, "Skipping on Unix systems")
    assert_not_nil(File::WIN32EXTS)
  end

  def self.shutdown
    @@windows = nil
  end
end
