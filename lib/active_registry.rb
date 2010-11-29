module ActiveRegistry
  def self.find_database(user_id)
    user = User.find_by_id(user_id)
    database = user.working_db.name + "_" + RAILS_ENV if user && user.working_db
    return database || CCOM_DATABASE
  end
end