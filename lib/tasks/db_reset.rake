namespace :db do

  desc "Drop all the Mongo database collections for the current environment"
  task :clear => :environment do |t|
    Mongoid.drop_all_collections
  end
end
