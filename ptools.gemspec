require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name       = 'ptools'
  spec.version    = '1.4.0'
  spec.license    = 'Artistic-2.0'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/ptools'
  spec.summary    = 'Extra methods for the File class'
  spec.test_files = Dir['spec/_spec*']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  spec.description = <<-EOF
    The ptools (power tools) library provides several handy methods to
    Ruby's core File class, such as File.which for finding executables,
    File.null to return the null device on your platform, and so on.
  EOF

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 3.9')

  if File::ALT_SEPARATOR
    spec.platform = Gem::Platform.new(['universal', 'mingw32'])
    spec.add_dependency('win32-file')
  end
end
