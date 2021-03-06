# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :hijack_db
  before_filter :authorize, :except => [:login, :build_first_user]
  
  protected  
  def hijack_db
    Mongoid.database.connection.close
    Mongoid.database = Mongo::Connection.new(MONGO_HOST,nil, :slave_ok => true).db(ROOT_DATABASE)
  end
  
  def authorize
    unless User.find_by_id(session[:user_id])
      if session[:user_id] != :logged_out
        authenticate_or_request_with_http_basic('Authentication required') do |username, password|
          user = User.authenticate(username, password)
          session[:user_id] = user.user_id if user
        end
      else
        flash[:notice] = "Please log in"
        redirect_to :controller => 'admin', :action => 'login'
      end
    end
  end
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
