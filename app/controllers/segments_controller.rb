class SegmentsController < ApplicationController

  before_filter :load_segment

  def show
    @uninstalled_assets = Asset.uninstalled
  end

  def update
    if @segment.update_attributes(params[:segment])
      case params[:commit]
      when "Install"
        asset = Asset.find_by_guid(params[:segment][:install_asset_id])
        flash[:notice] = "Installed #{asset.user_tag} on #{@segment.user_tag}"
      when "Uninstall"
        asset = Asset.find_by_guid(params[:segment][:delete_asset_id])
        flash[:notice] = "Uninstalled #{asset.user_tag} on #{@segment.user_tag}"
      end
    end
    redirect_to segment_url(@segment)

  end

  protected

  def load_segment
    @segment = Segment.find_by_guid(params[:id]) if params[:id]
  end
end
