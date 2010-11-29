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
  
  def attributes
    [:status, :ip_address, :time, :user_name, :database, :message, :operation]
  end
  
  def self.create(args = {})
    current_database = Mongoid.database.name
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    super args
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(current_database)
  end
  
  def user_name
    return "Anonymous" unless about_user
    about_user.name
  end
  
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