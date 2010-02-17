namespace :db do

  desc "Drop all the Mongo database collections for the current environment"
  task :clear => :environment do |t|
    Mongoid.database.collections.each do |collection|
      collection.drop
    end
  end
end
