class CcomRestController < ApplicationController
  
  #GET
  def index(entities = {})
    @entities = entities
    render :xml => CcomRest.build_entities(@entities)
  end
  
  def show
    render :xml => CcomEntity.find_by_guid(params[:id])
    #respond_to do |format|
  #    format.xml {render :xml => CcomEntity.find_by_guid(params[:id])}
  #    format.html {render :xml => CcomEntity.find_by_guid(params[:id])}
  #  end      
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
  def destroy
  end
  
end
