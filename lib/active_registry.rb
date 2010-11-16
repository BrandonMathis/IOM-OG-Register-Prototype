module ActiveRegistry
  def self.find_database(user_id)
    if user = User.find_by_id(user_id)
      database = user.working_db.name + "_dev"  if RAILS_ENV == 'development'
      database = user.working_db.name + "_prod" if RAILS_ENV == 'production'
      database = user.working_db.name + "_test" if RAILS_ENV == 'test'
    else
      database = CCOM_DATABASE
    end
    RAILS_DEFAULT_LOGGER.debug("***#{database}")
    return database
  end
end