require 'dotenv/tasks'

namespace :thin do
  desc "start the server"
  task :start => :dotenv do
    sh "thin start -C ./config/thin.yml"
  end

  desc "stop the server"
  task :stop => :dotenv do
    sh "thin stop -C ./config/thin.yml"
  end
end

task default: :"thin:start"

