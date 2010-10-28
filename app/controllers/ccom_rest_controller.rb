class CcomRestController < ApplicationController
  protect_from_forgery :only => []
  
  def index(entities = {})
    logger.debug(self.class)
    @entities = entities
    @entities = CcomEntity.find(:all) if self.class.to_s == "CcomRestController" #called by root controller
    render :xml => CcomRest.build_entities(@entities)
  end
  
  def show
    entity = CcomEntity.find_by_guid(params[:id])
    respond_to do |format|
      if entity
        response.etag = entity.last_edited
        format.xml {render :xml => entity.to_xml}
      else
        format.xml {render :xml =>CcomRest.error_xml({:method => "getCCOMEntity", :errorMessage => "Could not find requested CCOM Entity with given GUID", :guid => params[:id]}), :status => 404 }
      end
    end      
  end
  
  def create        
    render_this = CcomRest.construct_from_xml(request.body.read)
    render render_this
  end
  
  def update
    if entity = CcomEntity.find_by_guid(params[:id])
      response.etag = entity.last_edited
      if request.fresh?(response)
        render_this = CcomRest.construct_from_xml(request.body.read)
      else
        render_this = { :xml => CcomRest.error_xml({:method => "createEntity", :errorMessage => "Your Etag is old", :entity => "COMData"}), :status => 412 }
      end
    else
      render_this = { :xml => CcomRest.error_xml({:method => "createEntity", :errorMessage => "Could not find requested CCOM Entity with given GUID", :entity => params[:id]}), :status => 404}
    end
    render render_this
  end
  
  def destroy(entity = {})
    @entity = CcomEntity.find_by_guid(params[:id])
    respond_to do |format|
      if @entity
        entity_xml = @entity.to_xml
        @entity.destroy
        format.xml {render :xml => entity_xml}
      else
        format.xml { render :xml => CcomRest.error_xml({:method => "deleteEntity", :errorMessage => "Could not find requested CCOM Entity with given GUID", :guid => params[:id]}), :status => 404 }
      end
    end      
  end
end