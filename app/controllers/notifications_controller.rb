class NotificationsController < ReqAuthorizationController
  # GET /notifications
  # GET /notifications.xml
  def index
    @notifications = Notifications.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.xml
  def show
    @notifications = Notifications.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notifications }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.xml
  def new
    @notifications = Notifications.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notifications }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notifications = Notifications.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.xml
  def create
    @notifications = Notifications.new(params[:notifications])

    respond_to do |format|
      if @notifications.save
        flash[:notice] = 'Notifications was successfully created.'
        format.html { redirect_to(@notifications) }
        format.xml  { render :xml => @notifications, :status => :created, :location => @notifications }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @notifications.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.xml
  def update
    @notifications = Notifications.find(params[:id])

    respond_to do |format|
      if @notifications.update_attributes(params[:notifications])
        flash[:notice] = 'Notifications was successfully updated.'
        format.html { redirect_to(@notifications) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @notifications.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.xml
  def destroy
    @notifications = Notifications.find(params[:id])
    @notifications.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end
end
