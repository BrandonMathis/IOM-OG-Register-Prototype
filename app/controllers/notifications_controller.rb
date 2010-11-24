class NotificationsController < ReqAuthorizationController
  # GET /notifications
  # GET /notifications.xml
  def index
    @notifications = Notification.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.xml
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.xml
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notifications = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.xml
  def create
    @notifications = Notification.new(params[:notifications])

    respond_to do |format|
      if @notifications.save
        flash[:notice] = 'Notification was successfully created.'
        format.html { redirect_to notifications_path }
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
    @notifications = Notification.find(params[:id])

    respond_to do |format|
      if @notifications.update_attributes(params[:notifications])
        flash[:notice] = 'Notification was successfully updated.'
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
    @notifications = Notification.find(params[:id])
    @notifications.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.xml  { head :ok }
    end
  end
end
