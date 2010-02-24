class CcomDataController < ApplicationController

  def index
  end

  def create
    CcomData.from_xml(params[:file].read)
    redirect_to :action => "index"
  end
end
