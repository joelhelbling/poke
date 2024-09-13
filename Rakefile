require 'rspec/core/rake_task'
require 'dotenv/tasks'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = " --format doc"
end

namespace :puma do
  desc "Start the Puma server"
  task :start => :dotenv do
    sh "puma -C ./config/puma.rb"
  end

  desc "Stop the Puma server"
  task :stop do
    sh "pumactl -F ./config/puma.rb stop"
  end

  desc "Restart the Puma server"
  task :restart do
    sh "pumactl -F ./config/puma.rb restart"
  end
end

task server: :"puma:start"

namespace :db do
  desc "wipe out local data stores"
  task :reset do
    `rm -rf tmp/*`
  end
end

task default: :spec


