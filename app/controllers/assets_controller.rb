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
        flash[:notice] = "Product was successfully updated at #{@asset.last_edited}"
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
    @types = get_all_asset(:type)                          
    @manufacturers = get_all_asset(:manufacturer)
    @models = get_all_asset(:model)
    @networks = define_networks()
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
                      :i_d_in_info_source => passed_values[:i_d_in_info_source],
                      :status => "1",
                      :model => Model.find_by_guid(passed_values[:model]),
                      :manufacturer => Manufacturer.find_by_guid(passed_values[:manufacturer]),
                      :serial_number => passed_values[:serial_number])
                      
    @asset.update_attributes(:type => Type.find_by_guid(passed_values[:type]) || Type.undetermined )
    
    ref_valid_network = ValidNetwork.find_by_guid(passed_values[:valid_network])
    valid_network = ref_valid_network.nil? ? nil : ref_valid_network.dup_entity(:gen_new_guids => true)
    @asset.update_attributes( :valid_network => valid_network)
    
    respond_to do |format|
      if @asset.save
        flash[:notice] = "Asset was saved into database at #{@asset.last_edited}"
        format.html { redirect_to(@asset)}
      else
        @types = get_all_asset(:type)
        @manufacturers = get_all_asset(:manufacturer)
        @models = get_all_asset(:model)
        @networks = define_networks()
        format.html { render :action => "new" }
      end
    end
  end
  
  protected

    def load_asset
      @asset = Asset.find_by_guid(params[:id]) if params[:id]
    end
  
  private
    def get_all_asset(child)
      @all_assets = Asset.find(:all)
      children = []
      @all_assets.each{ |a| children << a.send("#{child}") unless a.nil? || a.send("#{child}").nil? || children.include?(a.send("#{child}")) }
      return children
    end
  
    def define_networks()
      @all_networks = ValidNetwork.find(:all)
      logged= []
      networks = []
      @all_networks.each do |n| 
        unless logged.include?(n.guid) || !n.network.tag[(/^(Data Sheet)/)]
          networks << n
          logged << n.guid
        end
      end
      return networks
    end
end
