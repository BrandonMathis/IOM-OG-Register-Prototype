class Database
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(SANDBOX_DATABASE)
  
  field :name
  field :created_date
  has_one :created_by, :class => "User"
  
  has_many_related :users
end
