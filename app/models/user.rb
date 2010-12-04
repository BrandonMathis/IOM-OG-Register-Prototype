class User
  include Mongoid::Document

  field :name
  field :salt
  field :hashed_password
  field :user_id
  field :databases, :type => Array, :default => []
  
  has_one :working_db, :class_name => "Database"  
  
  before_destroy :check_last
  before_save :generate_id
 
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validate :password_non_blank
  validates_presence_of     :name
  validates_uniqueness_of   :name
  
  before_save :set_defaults
  
  # Gives destroy the same functionality as delete
  def destroy; delete end
  
  # Deletes the user and the connections it may have to any dbs
  #
  # Databases are search for any references there may be to this user
  # that reference is then remove by deleting the user_id out of the
  # 'users' array
  def delete
    self.databases.each do |db_id|
      db = Database.find_by_id(db_id)
      db.users.delete(self.user_id) unless db.nil?
      db.save unless db.nil?
    end
    super
  end
  
  # Returns true if there are no users defined in the root database
  def self.none_exsist?
    current_database = Mongoid.database.name
    Mongoid.database.connection.close
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    x = User.find(:all).blank?
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(current_database)
    return x
  end
  
  # Returns the User found that has the given identifier in the root database
  def self.find_by_id(identifier)
    current_database = Mongoid.database.name
    Mongoid.database.connection.close
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    user = first(:conditions => { :user_id => identifier })
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(current_database)
    return user
  end
  
  # Returns the first User found that has the given name in the root database
  def self.find_by_name(name)
    current_database = Mongoid.database.name
    Mongoid.database.connection.close
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    user = first(:conditions => {:name => name})
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(current_database)
    return user
  end
  
  # Set the working database as the database with the given _id
  def working_db_id=(db_id)
    database = Database.find_by_id(db_id)
    self.working_db = database
    self.save
  end
  
  # Return true if the given username and password are a pair
  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end  
  
  # 'password' is a virtual attribute
  def password
    @password
  end
  
  # Salt's and encrypts the given password
  #
  # Returns false if the password is blank
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end    
  
  protected
  def check_last
    if User.find(:all).count == 1
      raise "Can't delete last user"
    end
  end
  
  def set_defaults; self.databases ||= [] end
  
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
