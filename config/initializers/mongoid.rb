connection = Mongo::Connection.new(MONGO_HOST, nil, :slave_ok => true)
Mongoid.database = connection.db(CCOM_DATABASE)

require 'mongoid_extensions'
require 'mongoid_association_extensions'
require 'mongoid_association_options_extensions'
