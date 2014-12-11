
namespace :thin do
  desc "start the server"
  task :start do
    sh "thin start -C ./config/thin.yml"
  end

  desc "stop the server"
  task :stop do
    sh "thin stop -C ./config/thin.yml"
  end
end

task default: :"thin:start"

