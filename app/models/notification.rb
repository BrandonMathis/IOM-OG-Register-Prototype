# A Notification store some information regard an action a user may
# had commited that resulted in the modification of the Active Registry
#
# These actions range from adding/deleting an entitiy to install/remove events
#
# A Notification is stored in the root Mongo database
class Notification
  include Mongoid::Document
  
  field :message
  field :level, :type => Integer
  field :time
  field :ip_address
  field :operation
  field :database
  field :ccom_entity
  
  has_one :about_user, :class_name => "User"
  
  before_save :define_time
  
  validate :is_valid_level
  
  # Defined the attributes of a Notification
  def attributes
    [:status, :ip_address, :time, :user_name, :database, :message, :operation]
  end
  
  # Will create a Notification in the root database using a hash of values
  def self.create(args = {})
    current_database = Mongoid.database.name
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    super args
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(current_database)
  end
  
  # Gives the name of the user and instance of Notification is about or Anonymous
  # if these was no logged in user at the time of the action
  def user_name
    return "Anonymous" unless about_user
    about_user.name
  end
  
  # Defines a sereies of 3 statuses that a Notification may have
  #
  # <tt>
  # 1 - Normal
  # 2 - High
  # 3 - Critical (this is reserved for major actions and should be used sparringly)
  # </tt>
  def status
    return "Normal" if level == 1
    return "High" if level == 2
    return "Critical" if level == 3
  end
  
  protected
  def define_time
    self.time = Time.now.strftime("%m/%d/%Y - %H:%M:%S")
  end
    
  def is_valid_level
    self.level ||= 1
    errors.add(:level, "Undefined level was given") unless (1..3).include? level
  end
end