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
  
  def whats_new
  end
    
  def delete_all
    Mongoid.drop_all_collections
    flash[:notice] = "Deleted all collections for database #{Mongoid.database.name}"
    redirect_to :action => :index
  end
  
  protected
  def authorize
  end
end
