class TopologiesController < ApplicationController

  def index
    @topologies = Asset.topologies
  end

  def show
    @topology = Asset.first(:conditions => { :g_u_i_d => params[:id]})
  end
end
