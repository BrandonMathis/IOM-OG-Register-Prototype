

connection = Mongo::Connection.new(MONGO_HOST)
Mongoid.database = connection.db(CCOM_DATABASE)

#if @settings["username"]
#  Mongoid.database.authenticate(@settings["username"], @settings["password"])
#end

require 'mongoid_extensions'
require 'mongoid_association_extensions'
require 'mongoid_association_options_extensions'
