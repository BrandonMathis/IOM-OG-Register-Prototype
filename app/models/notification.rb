class Notification
  include Mongoid::Document
  
  field :message
  field :level
  field :time
  field :ip
  field :type
  
  has_one :user
  has_one :database
  
  before_save :define_time, :define_user
  
  def level=(num)
    raise Exceptions::UnknownLevel if (1..3).include? num
  end
  
  def level
    return "Normal" if level == 1
    return "High" if level == 2
    return "Critical" if level == 3
  end
  
  protected
  def define_time
    
  end
  
  def define_user
  end
    
end
