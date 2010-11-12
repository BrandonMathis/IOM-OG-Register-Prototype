class ReqAuthorizationController < ApplicationController
  before_filter :hijack_db
  
  def hijack_db
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
  end
end
