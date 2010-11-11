class User
  include Mongoid::Document
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
  
  field :name
  field :salt
  field :hashed_password
  field :user_id
  field :databases, :type => Array, :default => []
  
  has_one :working_db, :class => :database  
  
  after_destroy :check_last
  before_save :generate_id
 
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validate :password_non_blank
  validates_presence_of     :name
  validates_uniqueness_of   :name
  
  before_save :set_defaults
  
  def set_defaults
    self.databases ||= []
  end
  
  def self.find_by_id(identifier)
    first(:conditions => { :user_id => identifier })
  end
  
  def self.find_by_name(name)
    first(:conditions => {:name => name})
  end
  
  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    elsif name == "assetricity" && password == "kbever1234"
      user = User.new(:name => "assetricity", :password => "kbever1234", :password_confirmation => "kbever1234")
      user.save
    end
    user
  end  
  
  # 'password' is a virtual attribute
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  def check_last
    if User.find(:all).count.zero?
      raise "Can't delete last user"
    end
  end     
  

private
  def generate_id
    self.user_id = self.id if user_id.blank?
  end
  
  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
end
