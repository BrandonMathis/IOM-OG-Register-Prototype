class AdminController < ReqAuthorizationController  
  
  def build_first_user
    if User.find(:all).blank?
      new_user = User.new(:name => "assetricity", :password => "kbever1234", :password_confirmation => "kbever1234")
      new_user.save
    end
    flash[:notice] = "Built initial user #{User.find(:all).first.name}"
    redirect_to(:controller => "ccom_data", :action => "index")
  end
  
  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.user_id
        Notification.create(
                  :message => "User #{user.name} has logged in", 
                  :ip_address => request.remote_ip,
                  :operation => "User Login", 
                  :about_user => User.find_by_id(session[:user_id]), 
                  :database => ActiveRegistry.find_database(session[:user_id])
        )
        flash[:notice] = "Successfully logged in"
        render :template => "ccom_data/index"
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end
  
  def logout
    Notification.create(
              :message => "User #{User.find_by_id(session[:user_id]).name} has logged out", 
              :ip_address => request.remote_ip,
              :operation => "User Logout", 
              :about_user => User.find_by_id(session[:user_id]), 
              :database => ActiveRegistry.find_database(session[:user_id])
    )
    session[:user_id] = :logged_out
    flash[:notice] = "Logged out"
    redirect_to(:action => "login")
  end
  
  def dump_all_databases
    Notification.create(
              :message => "Record of all databases has been cleared", 
              :ip_address => request.remote_ip,
              :operation => "dump all databases", 
              :about_user => User.find_by_id(session[:user_id]), 
              :database => ActiveRegistry.find_database(session[:user_id])
    )
    previous_db = Mongoid.database.name
    Mongoid.database.connection.close
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    Mongoid.database.collection("databases").drop
    User.find(:all).each {|x| x.databases = []; x.save }
    flash[:notice] = "All references to exsisting databases have been cleared from the root database"
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(previous_db)
    redirect_to :controller => 'databases', :action => 'index'
  end
end
