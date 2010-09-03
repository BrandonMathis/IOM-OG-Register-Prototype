class CcomController < ApplicationController
  
  before_filter :load_asset
  
  def index
    @assets = Asset.all
    respond_to do |format|
     format.xml  { render :layout => false}
     format.html { render :layout => false }
    end
  end
  
  def show
    respond_to do |format|
     format.xml  { render :layout => false}
     format.html { render :layout => false }
    end
  end
  
  def new
    @all_networks = ValidNetwork.find(:all)
    @all_assets = Asset.find(:all)
    @types = []
    @networks = []
    @all_assets.each{ |a| @types << a.type unless @types.include?(a.type)}
    @all_networks.each{ |n| @networks << n unless @networks.include?(n) }
    respond_to do |format|
      format.html
    end
  end
  
  def create
    passed_values = params[:entity]
    @entity = Asset.create(passed_values)
    @entity.update_attributes(:valid_network => ValidNetwork.find_by_guid(passed_values[:network_id]))
    
    respond_to do |format|
      if @entity.save
        flash[:notice] = "Asset was saved into database"
        format.html { redirect_to(:controller => 'assets')}
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  protected
  def load_asset
    @asset = Asset.find(:all, :conditions => {:g_u_i_d => params[:id]})
  end  
end