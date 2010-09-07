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
  
  # Setup for the Entity Creation Form
  # Types and Valid Networks are pulled from exsisting Assets which should
  # have been uploaded via CCOM XML (or maybe defined by admin in future)
  #
  # Dup Networks and Types are ignored if they are 100% similar. The slightest
  # difference will cause the type or network to be included in the dropdown
  def new
    @all_networks = ValidNetwork.find(:all)
    @all_assets = Asset.find(:all)
    @types = []
    @networks = []
    @all_assets.each{ |a| @types << a.type unless a.type.nil? || @types.include?(a.type)}
    @all_networks.each{ |n| @networks << n unless @networks.include?(n) }
    respond_to do |format|
      format.html
    end
  end
  
  # Create Entity for has been submitted. We run a lookup for ValidNetwork
  # and Type based off GUID passed by the form (identifying what Type and
  # ValidNetwork were selected)
  #
  # Top level elements are passed in a manner that can be used right away 
  # by the mongoid create function
  #
  # User is redirectred to Assets page uppon form submission
  def create
    passed_values = params[:entity]
    @entity = Asset.create(passed_values)
    @entity.update_attributes(
                    :status => "1",
                    :valid_network => ValidNetwork.find_by_guid(passed_values[:network_id]),
                    :type => Type.find_by_guid(passed_values[:type_id]))
    
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