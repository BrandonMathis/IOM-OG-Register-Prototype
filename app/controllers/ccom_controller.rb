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
  
  protected
  
  def load_asset
    @asset = Asset.find(:all, :conditions => {:g_u_i_d => params[:id]})
  end  
end