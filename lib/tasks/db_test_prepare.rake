Rake::Task["db:test:prepare"].clear

namespace :db do
  namespace :test do
    task :prepare => :environment do
      Mongoid.database.collection(:test).drop
    end
  end
end
