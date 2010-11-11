class CcomDataController < ApplicationController
  Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(CCOM_DATABASE)
  
  def index
  end
  
  def create
    begin    
      CcomData.from_xml(params[:file].read, :edit => true)
    rescue Exceptions::BadGuid => a
      flash[:error] = "Sorry, but a bad GUID was detected in your XML"
    else
      flash[:notice] = "Upload completed."
    ensure
      redirect_to :action => "index"
    end
  end
  
  def whats_new
  end
    
  def delete_all
    CcomData.drop_all_collections
    flash[:notice] = "Deleted all collections for database #{Mongoid.database.name}"
    redirect_to :action => :index
  end
  
  protected
  def authorize
  end
end
