class AdminController < ReqAuthorizationController  
  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.user_id
        flash[:notice] = "Successfully logged in"
        render :template => "ccom_data/index"
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end
  
  def logout
    session[:user_id] = :logged_out
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end
end
