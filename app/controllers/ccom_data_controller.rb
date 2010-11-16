class CcomDataController < ApplicationController
  before_filter :hijack_db
  
  def hijack_db
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(ActiveRegistry.find_database session[:user_id])
  end
  
  def index
    logger.debug("^^^#{Mongoid.database.name}")
  end
  
  def create
    if params[:file].nil?
      flash[:error] = "Please specify an XML file to upload"
    else
      begin
        CcomData.from_xml(params[:file].read, :edit => true) if params[:file]
      rescue Exceptions::BadGuid => a
        flash[:error] = "Sorry, but a bad GUID was detected in your XML"
      else
        flash[:notice] = "Upload completed." if params[:file]
      end
    end
    redirect_to :action => "index"
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
