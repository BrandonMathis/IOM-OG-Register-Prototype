set :application, "ARplatform"
set :user, "deploy"

set :scm, :git
set :repository, "git@github.com:assetricity/mimosa-active-registry.git"

set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache

set :domain, "activeregistry.assetricity.com"
role :app, domain
role :web, domain

set :runner, user
set :admin_runner, runner

namespace :deploy do
  task :restart do
    deploy.stop
    deploy.start
  end

  task :start do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop do
  end

  task :cold do
    deploy.update
  end

  task :symlink_stuff do
    run "rm -rf #{current_path}/events"
    run "ln -nfs #{shared_path}/events #{current_path}/"
  end
end

after "deploy:symlink", "deploy:symlink_stuff"
