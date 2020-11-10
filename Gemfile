source 'https://rubygems.org'

gem 'structured_warnings'

group :production do
  gem 'win32-file' if File::ALT_SEPARATOR
end

group :test do
  gem 'rake'
  gem 'rspec', '~> 3.9'
end

group :development do
  gem 'rubocop', '~> 1.1'
end
