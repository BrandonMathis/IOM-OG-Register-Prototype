class CcomDataController < ApplicationController
  
  def index
  end
  
  def create
    CcomData.from_xml(params[:file].read)
  rescue Exceptions::BadGuid
    flash[:error] = "Sorry, but a bad GUID was detected in your XML"
  else
    flash[:notice] = "Upload completed."
  ensure
    redirect_to :action => "index"
  end
    
  def delete_all
    Mongoid.drop_all_collections
    redirect_to :action => :index
  end
end
