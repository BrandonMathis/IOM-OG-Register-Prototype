class TopologiesController < ApplicationController

  def show
    @topology = Asset.first(:conditions => { :guid => params[:id]})
    @entry_point = @topology.network.entry_points.first 
  end
end
