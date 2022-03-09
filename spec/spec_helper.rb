require 'ptools'
require 'rspec'

RSpec.configure do |config|
  config.filter_run_excluding(:windows_only) unless Gem.win_platform?
  config.filter_run_excluding(:unix_only) if Gem.win_platform?
end
