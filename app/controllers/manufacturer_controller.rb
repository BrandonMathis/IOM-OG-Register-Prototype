class ManufacturerController < CcomRestController
  def index
    super(Manufacturer.find(:all))
  end
  
  def new
    @manufacturer = Manufacturer.new
    respond_to do |format|
      format.html
    end
  end
  
  def create
    if request.format == :xml
      super
    else
      @manufacturer = Manufacturer.create(params[:manufacturer])
      respond_to do |format|
        if @manufacturer.save
          format.html {redirect_to new_asset_path}
        else
          format.html {render :action=> "new"}
        end
      end
    end
  end
end
