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
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @entity = Asset.create(params[:entity])
    
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