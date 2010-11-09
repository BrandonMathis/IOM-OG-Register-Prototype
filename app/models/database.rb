class Database
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
  
  field :name
  field :created_date
  has_one :created_by, :class => "User"
  
  has_many :users
  
  validates_presence_of     :name
  validates_uniqueness_of   :name
end
