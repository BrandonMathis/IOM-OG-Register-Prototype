set :application, "assetricity"
set :user, "deploy"

set :scm, :git
set :repository, "git@github.com:dougalcorn/mimosa-active-registry.git"

set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache

set :domain, "#{application}.gaslightsoftware.com"
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
  end

  task :stop do
  end

  task :cold do
    deploy.update
  end

  task :symlink_events do
    run "ln -nfs #{shared_path}/public/events #{current_path}/public"
  end
end

after "deploy:symlink", "deploy:symlink_events"