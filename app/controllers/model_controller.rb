class ModelController < CcomRestController
  def index
    super(Model.find(:all))
  end
  
  def new
    @model = Model.new
    respond_to do |format|
      format.html
    end
  end
  
  def create
    if request.format == :xml
      super
    else
      @model = Model.create(params[:model])
      respond_to do |format|
        format.html {redirect_to new_asset_path}
      end
    end
  end
end
