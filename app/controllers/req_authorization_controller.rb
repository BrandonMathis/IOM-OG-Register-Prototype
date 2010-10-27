class ReqAuthorizationController < ApplicationController
  def authorize
    unless User.find_by_id(session[:user_id])
      if session[:user_id] != :logged_out
        authenticate_or_request_with_http_basic('Authentication required') do |username, password|
          user = User.authenticate(username, password)
          session[:user_id] = user.user_id if user
        end
      else
        flash[:notice] = "Please log in"
        redirect_to :controller => 'users', :action => 'login'
      end
    end
  end
end
