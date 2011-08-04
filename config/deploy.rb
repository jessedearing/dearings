require 'bundler/capistrano'

set :application, "dearings"
set :repository,  "git@github.com:jessedearing/dearings.git"
set :deploy_to, '/var/www/dearings'
set :rails_env, 'production'
set :user, 'jessed'
set :use_sudo, false

set :scm, :git

role :web, "dearin.gs"                          # Your HTTP server, Apache/etc
role :app, "dearin.gs"                          # This may be the same as your `Web` server

namespace :deploy do
  task :start do
    run "cd #{current_path} && #{sudo} unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
  end
  task :stop do
    run "#{sudo} kill -QUIT $(cat #{current_path}/tmp/pids/unicorn.pid)"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} kill -USR2 $(cat #{current_path}/tmp/pids/unicorn.pid)"
  end
  task :create_cache_dirs do
    run "cd #{current_path} && #{sudo} mkdir tmp/cache"
    run "cd #{current_path} && #{sudo} mkdir tmp/sessions"
    run "cd #{current_path} && #{sudo} chown -R www-data:www-data tmp"
  end
end
