class SegmentsController < ApplicationController

  before_filter :load_segment

  def show
    @uninstalled_assets = Asset.uninstalled
  end

  def update
    if @segment.update_attributes(params[:segment])
      asset = @segment.installed_assets.last
      flash[:notice] = "Installed #{asset.user_tag} on #{@segment.user_tag}"
    end
    redirect_to segment_url(@segment)

  end

  protected

  def load_segment
    @segment = Segment.find_by_guid(params[:id]) if params[:id]
  end
end
