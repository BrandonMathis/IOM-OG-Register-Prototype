class AdminController < ReqAuthorizationController  
  #before_filter :build_first_user
  
  def build_first_user
    if User.find(:all).blank?
      User.create(:name => "assetricity", :password => "kbever1234", :password_confirmation => "kbever1234")
    end
    flash[:notice] = "Built initial user #{User.find(:all).first.name}"
    redirect_to(:controller => "ccom_data", :action => "index")
  end
  
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
  
  def dump_all_databases
    previous_db = Mongoid.database.name
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ROOT_DATABASE)
    Mongoid.database.collection("databases").drop
    User.find(:all).each {|x| x.databases = []; x.save }
    flash[:notice] = "All references to exsisting databases have been cleared from the root database"
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(previous_db)
    redirect_to :controller => 'databases', :action => 'index'
  end
end
