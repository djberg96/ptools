require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
require 'rspec/core/rake_task'
include RbConfig

CLEAN.include("**/*.gem", "**/*.rbc", "**/*coverage*")

desc 'Install the ptools package (non-gem)'
task :install do
  sitelibdir = CONFIG["sitelibdir"]
  file = "lib/ptools.rb"
  FileUtils.cp(file, sitelibdir, :verbose => true)
end

namespace 'gem' do
  desc 'Create the ptools gem'
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('ptools.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc 'Install the ptools gem'
  task :install => [:create] do
    file = Dir["*.gem"].first
    if RUBY_PLATFORM == 'java'
      sh "jruby -S gem install -l #{file}"
    else
      sh "gem install -l #{file}"
    end
  end
end

namespace 'spec' do
  RSpec::Core::RakeTask.new(:binary) do |t|
    t.pattern = 'spec/binary_spec.rb'
  end

  RSpec::Core::RakeTask.new(:constants) do |t|
    t.pattern = 'spec/constants_spec.rb'
  end

  RSpec::Core::RakeTask.new(:head) do |t|
    t.pattern = 'spec/head_spec.rb'
  end

  RSpec::Core::RakeTask.new(:image) do |t|
    t.pattern = 'spec/image_spec.rb'
  end

  RSpec::Core::RakeTask.new(:nlconvert) do |t|
    t.pattern = 'spec/nlconvert_spec.rb'
  end

  RSpec::Core::RakeTask.new(:sparse) do |t|
    t.pattern = 'spec/sparse_spec.rb'
  end

  RSpec::Core::RakeTask.new(:tail) do |t|
    t.pattern = 'spec/tail_spec.rb'
  end

  RSpec::Core::RakeTask.new(:touch) do |t|
    t.pattern = 'spec/touch_spec.rb'
  end

  RSpec::Core::RakeTask.new(:wc) do |t|
    t.pattern = 'spec/wc_spec.rb'
  end
 
  RSpec::Core::RakeTask.new(:whereis) do |t|
    t.pattern = 'spec/whereis_spec.rb'
  end

  RSpec::Core::RakeTask.new(:which) do |t|
    t.pattern = 'spec/which_spec.rb'
  end

  RSpec::Core::RakeTask.new(:all) do |t|
    t.pattern = 'spec/*_spec.rb'
  end
end

task :default => 'spec:all'
