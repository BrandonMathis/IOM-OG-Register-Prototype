class DatabasesController < ReqAuthorizationController
  # GET /databases
  # GET /databases.xml
  def index
    @databases = Database.find(:all)

    respond_to do |format|
      format.html
    end
  end

  # GET /databases/1
  # GET /databases/1.xml
  def show
    @database = Database.find(params[:id])
    @users = @database.users.collect { |id| User.find_by_id(id) }
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /databases/new
  # GET /databases/new.xml
  def new
    @database = Database.new
    @users = User.find(:all)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /databases/1/edit
  def edit
    @database = Database.find(params[:id])
    @users = User.find(:all)
  end

  # POST /databases
  # POST /databases.xml
  def create
    @database = Database.new(params[:database])
    @database.created_by = User.find_by_id(params[:database][:user_id])
    params[:users].each { |id| @database.add_user User.find_by_id(id) } if params[:users]
    respond_to do |format|
      if @database.save
        flash[:notice] = 'Database was successfully created.'
        format.html { redirect_to(@database) }
      else
        @users = User.find(:all)
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /databases/1
  # PUT /databases/1.xml
  def update
    @database = Database.find(params[:id])
    if params[:users]
      params[:users].each { |id| @database.add_user User.find_by_id(id) }
    else
      @database.empty_users
    end
    respond_to do |format|
      if @database.update_attributes(params[:database])
        flash[:notice] = 'Database was successfully updated.'
        format.html { redirect_to(@database) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /databases/1
  # DELETE /databases/1.xml
  def destroy
    @database = Database.find(params[:id])
    @database.destroy

    respond_to do |format|
      format.html { redirect_to(databases_url) }
    end
  end
end
