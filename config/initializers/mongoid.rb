File.open(File.join(RAILS_ROOT, 'config/database.mongoid.yml'), 'r') do |f|
  @settings = YAML.load(f)[RAILS_ENV]
end

connection = Mongo::Connection.new(@settings["host"])
Mongoid.database = connection.db(@settings["database"])

if @settings["username"]
  Mongoid.database.authenticate(@settings["username"], @settings["password"])
end

require 'mongoid_association_extensions'
require 'mongoid_association_options_extensions'