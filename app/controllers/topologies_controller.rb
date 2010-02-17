class TopologiesController < ApplicationController

  def show
    @topology = TopologyAsset.first(:conditions => { :guid => params[:id]})
  end
end
