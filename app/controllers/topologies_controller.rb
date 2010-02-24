class TopologiesController < ApplicationController

  def index
    @topologies = Asset.topologies
  end

  def show
    @topology = Asset.first(:conditions => { :guid => params[:id]})
  end
end
