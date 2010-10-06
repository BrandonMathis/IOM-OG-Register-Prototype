class SegmentsController < CcomRestController

  before_filter :load_segment
  
  def index 
    super(Segment.find(:all))
  end

  def show
    @uninstalled_assets = Asset.uninstalled
    respond_to do |format|
      format.html {}
      format.js { render :layout => false}
    end
  end

  def update
    if @segment.update_attributes(params[:segment])
      case params[:commit]
      when "Install"
        asset = Asset.find_by_guid(params[:segment][:install_asset_id])
        #flash[:notice] = "Installed #{asset.tag} on #{@segment.tag}"
      when "Uninstall"
        asset = Asset.find_by_guid(params[:segment][:delete_asset_id])
        #flash[:notice] = "Uninstalled #{asset.tag} on #{@segment.tag}"
      end
    end
    @uninstalled_assets = Asset.uninstalled
    respond_to do |format|
      format.html { redirect_to segment_url(@segment) }
      format.js { render :action => :show, :layout => false}
    end
  end

  protected

  def load_segment
    @segment = Segment.find_by_guid(params[:id]) if params[:id]
  end
end
