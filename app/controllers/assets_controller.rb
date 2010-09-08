class AssetsController < ApplicationController

  before_filter :load_asset

  def destroy
    @entity = Asset.find_by_guid(params[:id])
    @entity.destroy
    
    respond_to do |format|
      format.html { redirect_to(:controller => 'assets') }
    end
  end
  
  def index
    @assets = Asset.serialized
  end

  def show
    respond_to do |format|
      format.html {}
      format.js { render :layout => false}
      format.xml  { render :layout => false}
    end
  end
  
  def edit
    @asset = Asset.find_by_guid(params[:id])
  end
  
  def update
    @asset = Asset.find_by_guid(params[:id])
    
    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        flash[:notice] = 'Product was successfully updated'
        format.html { redirect_to(@asset) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # Setup for the Entity Creation Form
  # Types and Valid Networks are pulled from exsisting Assets which should
  # have been uploaded via CCOM XML (or maybe defined by admin in future)
  #
  # Dup Networks and Types are ignored if they are 100% similar. The slightest
  # difference will cause the type or network to be included in the dropdown
  def new
    @asset = Asset.new
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
    passed_values = params[:asset]
    @asset = Asset.create(
                      :g_u_i_d => passed_values[:g_u_i_d],
                      :tag => passed_values[:tag],
                      :name => passed_values[:name],
                      :i_d_in_info_source => passed_values[:i_d_in_info_source])
    @asset.update_attributes(
                    :status => "1",
                    :valid_network => ValidNetwork.find_by_guid(passed_values[:valid_network]),
                    :type => Type.find_by_guid(passed_values[:type]))
    
    respond_to do |format|
      if @asset.save
        flash[:notice] = "Asset was saved into database"
        format.html { redirect_to(:controller => 'assets')}
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  protected

  def load_asset
    @asset = Asset.find_by_guid(params[:id]) if params[:id]
  end
end
