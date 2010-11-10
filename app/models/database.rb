class Database
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
  
  field :name
  field :created_date
  field :users, :type => Array, :default => []
  
  has_one :created_by, :class => "User"
      
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
    RAILS_DEFAULT_LOGGER.debug(self.users.count)
    self.users.each do |id|
      user = User.find_by_id(id)
      self.users.delete(user.user_id)
      user.databases.delete(self._id)
      RAILS_DEFAULT_LOGGER.debug("Removed #{id}")
    end
    RAILS_DEFAULT_LOGGER.debug("***#{self.users}")
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
      user.databases.delete(self._id)
      user.save
     end
    super
  end
end
