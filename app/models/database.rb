class Database
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(SANDBOX_DATABASE)
  
  field :name
  
  has_many_related :users
end
