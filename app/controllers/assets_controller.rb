class AssetsController < ApplicationController

  before_filter :load_asset

  def index
    @assets = Asset.serialized
  end

  def show
    respond_to do |format|
      format.html {}
      format.js { render :layout => false}
    end
  end

  
  protected

  def load_asset
    @asset = Asset.find_by_guid(params[:id]) if params[:id]
  end
end
