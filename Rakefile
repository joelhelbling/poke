require 'rspec/core/rake_task'
require 'dotenv/tasks'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
  t.rspec_opts = " --format doc"
end

namespace :thin do
  desc "start the server"
  task :start => :dotenv do
    sh "thin start -C ./config/thin.yml"
  end
end

task thin: :"thin:start"

namespace :env do
  namespace :hydrate do
    desc "hydrate configs for development environment"
    task :development do
      sh "cp config/thin.yml.development config/thin.yml"
    end
  end
end

task default: :spec


