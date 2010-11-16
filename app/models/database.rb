class Database
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
  
  field :name
  field :created_date
  field :users, :type => Array, :default => []
  
  has_one :created_by, :class_name => "User"
      
  validates_presence_of     :name
  validates_presence_of     :created_date
  validates_uniqueness_of   :name
  
  before_save :set_defaults
  
  def set_defaults
    self.users ||= []
  end
  
  def destroy; delete end
  
  def self.find_by_id(identifier)
    first(:conditions => { :_id => identifier })
  end
  
  def add_user(user)
    return false if self.users.include? user.user_id
    self.users = (users || []) + [user.user_id] 
    user.databases = (user.databases || []) + [self._id]
    user.save
    self.save
  end
  
  def empty_users
    user_list = Array.new(self.users)
    user_list.each { |id| remove_user User.find_by_id(id) }
  end
  
  def remove_user(user)
    self.users.delete(user.user_id)
    user.databases.delete(self._id)
    self.save
    user.save
  end
  
  def delete
    self.users.each do |id|
      user = User.find_by_id(id)
      user.databases.delete(self._id) unless user.nil?
      user.save unless user.nil?
     end
    super
  end
  
  def ==(object)
    self._id == object._id rescue false
  end
end
