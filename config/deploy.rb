#this works great except i think
#it's running against system ruby
#not rvm 1.9.2
#http://blog.ninjahideout.com/posts/a-guide-to-a-nginx-passenger-and-rvm-server
#require "bundler/capistrano"

set :application, "jday"
set :domain,      "ec2-user@judgementdayconfessions.com"
set :repository,  "git@github.com:kylefritz/judgement-day-confessions.git"
set :use_sudo,    false
set :deploy_to,   "/passenger/#{application}"
set :scm,         "git"
set :scm_verbose, true
set :user,        "ec2-user"
set :deploy_via,  :remote_cache

#the trick to make this work was to follow
#http://dysinger.net/2008/04/30/deploying-with-capistrano-git-and-ssh-agent/
ssh_options[:forward_agent] = true

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

