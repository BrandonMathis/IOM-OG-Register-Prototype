module ActiveRegistry
  def self.find_database(user_id)
    if user = User.find_by_id(user_id)
      user.working_database
    else
      CCOM_DATABASE
    end
    return CCOM_DATABASE
  end
end