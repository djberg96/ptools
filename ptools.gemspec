require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |gem|
  gem.name       = 'ptools'
  gem.version    = '1.2.1'
  gem.license    = 'Artistic 2.0'
  gem.author     = 'Daniel J. Berger'
  gem.email      = 'djberg96@gmail.com'
  gem.homepage   = 'http://www.rubyforge.org/projects/shards'
  gem.summary    = 'Extra methods for the File class'
  gem.test_files = Dir['test/test*']
  gem.has_rdoc   = true
  gem.files      = Dir['**/*'].reject{ |f| f.include?('CVS') || f.include?('git') }

  gem.rubyforge_project = 'shards'
  gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  gem.description = <<-EOF
    The ptools (power tools) library provides several handy methods to
    Ruby's core File class, such as File.which for finding executables,
    File.null to return the null device on your platform, and so on.
  EOF

  gem.add_development_dependency('test-unit', '>= 2.0.7')

  if Config::CONFIG['host_os'] =~ /mswin|win32|msdos|cygwin|mingw|windows/i
    gem.platform = Gem::Platform::CURRENT
    gem.add_dependency('win32-file', '>= 0.5.4')
  end
end
