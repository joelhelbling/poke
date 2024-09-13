# Puma configuration file
environment ENV['RACK_ENV'] || 'development'
port        ENV['PORT'] || 9995
workers     ENV['WEB_CONCURRENCY'] || 2
threads     1, 5

preload_app!

rackup      DefaultRackup
pidfile     ENV['PIDFILE'] || 'tmp/pids/puma.pid'
state_path  ENV['STATE_PATH'] || 'tmp/pids/puma.state'
stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true

on_worker_boot do
  # Worker specific setup
end

plugin :tmp_restart
