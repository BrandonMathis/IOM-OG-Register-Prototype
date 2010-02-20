class AssetsController < ApplicationController

  before_filter :load_asset

  def show
  end

  
  protected

  def load_asset
    @asset = Asset.find_by_guid(params[:id]) if params[:id]
  end
end
