class TopologiesController < ApplicationController

  def show
    @topology = Asset.first(:conditions => { :guid => params[:id]})
  end
end
