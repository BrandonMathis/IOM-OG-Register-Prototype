class Notification
  include Mongoid::Document
  
  field :message
  field :level, :type => Integer
  field :time
  field :ip
  field :operation
  
  has_one :user
  has_one :database
  
  before_save :define_time, :define_user
  
  validate :is_valid_level
  
  def status
    return "Normal" if level == 1
    return "High" if level == 2
    return "Critical" if level == 3
  end
  
  protected
  def define_time
    self.time = CcomEntity.get_time
  end
  
  def define_user
    self.user = User.find_by_id(session[:user_id]) rescue nil
  end
    
  def is_valid_level
    self.level ||= 1
    errors.add(:level, "Undefined level was given") unless (1..3).include? level
  end
end