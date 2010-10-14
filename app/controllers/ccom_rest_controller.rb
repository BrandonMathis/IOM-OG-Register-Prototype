class CcomRestController < ApplicationController
  protect_from_forgery :only => [:update, :delete]
  
  #GET
  def index(entities = {})
    @entities = entities
    @entities = CcomEntity.find(:all) if @entities.blank?
    render :xml => CcomRest.build_entities(@entities)
  end
  
  def show
    respond_to do |format|
      format.xml {render :xml => CcomEntity.find_by_guid(params[:id])}
      format.html {render :xml => CcomEntity.find_by_guid(params[:id])}
    end      
  end
  
  #POST  
  def create
    entities = CcomData.from_xml(request.body.read)
  rescue Exceptions::BadGuid
    respond_to do |format|
      format.xml { render :xml =>CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given XML contains an invalid value for GUID", :entity => "CCOMData"}), :status => 500 }
    end
  else
    respond_to do |format|
      if entities
        format.xml { render :xml => CcomRest.build_entities(entities), :status => 201 }
      else
        format.xml { render :xml => CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given XML is invalid", :entity => "COMData"}), :status => 500 }
      end
    end 
  end
  
  #PUT
  def edit
  end
  
  #DELETE
  def destroy(entity = {})
    @entity = CcomEntity.find_by_guid(params[:id])
    entity_xml = @entity.to_xml
    @entity.destroy
    respond_to do |format|
      if @entity
        format.xml {render :xml => entity_xml}
      else
        format.xml { render :xml => CcomRest.error_xml({:method => "deleteEntity", :errorMessage => "Could not find requested CCOM Entity with the given GUID: #{params[:id]}", :entity => "COMData"}), :status => 404 }
      end
    end      
  end
end