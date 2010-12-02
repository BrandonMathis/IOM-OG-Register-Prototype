# A Database defines a Mimosa CCOM Database that can have
# users attached to is. These databases are treated as 
# seperate sandboxes for the users as to keep a user' data
# free of interference from the actions of other users using
# other sandboxes. The name of the database defines the name
# of the Mongo database and is the key to keeping these dbs
# seperate from one another
class Database
  include Mongoid::Document
  
  field :name
  field :created_date
  field :users, :type => Array, :default => []
  
  has_one :created_by, :class_name => "User"
      
  validates_presence_of     :name
  validates_presence_of     :created_date
  validates_uniqueness_of   :name
  
  validates_format_of :name,
                      :with => /^[A-Za-z\d_]+$/,
                      :message => "cannot have any spaces"
  
  before_save :set_defaults
  
  # Directs destroy to the same functionality as delete
  def destroy; delete end
  
  # Gives the first occurance of a Database with the given _id
  def self.find_by_id(identifier)
    first(:conditions => { :_id => identifier })
  end
  
  # Attach a user to an instance of Database  
  def add_user(user)
    return false if self.users.include? user.user_id
    self.users = (users || []) + [user.user_id] 
    user.databases = (user.databases || []) + [self._id]
    user.save
    self.save
  end
  
  # Clear all users from an instance of Database
  def empty_users
    user_list = Array.new(self.users)
    user_list.each { |id| remove_user User.find_by_id(id) }
  end
  
  # Unattach a user from an instance of Database
  def remove_user(user)
    self.users.delete(user.user_id)
    user.databases.delete(self._id)
    self.save
    user.save
  end
  
  # Delete an instance of Database
  # 
  # <tt>
  # Must first unnattach all users from the database
  # and then make sure that no users are using the deleted
  # database as a working database
  # </tt>
  def delete
    self.users.each do |id|
      user = User.find_by_id(id)
      next if user.nil?
      user.databases.delete(self._id)
      user.working_db_id = nil if user.working_db == self
      user.save
     end
    super
  end
  
  # Comparing two Databases will compare the databases _id
  def ==(object)
    self._id == object._id rescue false
  end
  
  protected
  def set_defaults
    self.users ||= []
  end
end
