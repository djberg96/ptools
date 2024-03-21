require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name       = 'ptools'
  spec.version    = '1.5.0'
  spec.license    = 'Apache-2.0'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/ptools'
  spec.summary    = 'Extra methods for the File class'
  spec.test_files = Dir['spec/_spec*']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.description = <<-EOF
    The ptools (power tools) library provides several handy methods to
    Ruby's core File class, such as File.which for finding executables,
    File.null to return the null device on your platform, and so on.
  EOF

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/ptools',
    'bug_tracker_uri'       => 'https://github.com/djberg96/ptools/issues',
    'changelog_uri'         => 'https://github.com/djberg96/ptools/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/ptools/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/ptools',
    'wiki_uri'              => 'https://github.com/djberg96/ptools/wiki',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-rspec')

  if File::ALT_SEPARATOR
    spec.platform = Gem::Platform.new(['universal', 'mingw32'])
    spec.add_dependency('win32-file')
  end

  spec.post_install_message = <<-EOF

  #############################################################################
  # Amendment VIII of the US Constitution                                     #
  #                                                                           #
  # Excessive bail shall not be required, nor excessive fines imposed, nor    #
  # cruel and unusual punishments inflicted.                                  #
  #############################################################################

  EOF
end
