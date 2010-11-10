class Database
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
  
  field :name
  field :created_date
  
  field :users, :type => Array
  
  has_one :created_by, :class => "User"
      
  validates_presence_of     :name
  validates_presence_of     :created_date
  validates_uniqueness_of   :name
  
  def destroy; delete end
  
  def self.find_by_id(identifier)
    first(:conditions => { :_id => identifier })
  end
  
  def add_user(user)
    self.users = (self.users || []) + [user.user_id]
    user.databases = (user.databases || []) + [self._id]
    self.save
    user.save
  end
  
  def remove_user(user)
    self.users.delete(user.user_id)
    user.databases.delete(self._id)
  end
  
  def delete
    self.users.each do |id|
      User.find_by_id(id).databases.delete(self._id)
     end
    super
  end
end
