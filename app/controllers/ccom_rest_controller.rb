class CcomRestController < ApplicationController
  def index(entities = {})
    @entities = entities
    logger.debug("#{@entities}")
    render :file => "/ccom_rest/index.xml.builder"
  end
  def create
    entities = CcomData.from_xml(request.body.read)
  rescue
    respond_to do |format|
      format.xml { render :xml =>CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given XML contains an invalid value for GUID", :entity => "CCOMData"}), :status => 500 }
    end
  else
    respond_to do |format|
      if entities
        format.xml { render :xml => CcomRest.build_entities(entities), :status => :created }
      else
        format.xml { render :xml =>CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given XML is invalid", :entity => "COMData"}), :status => 500 }
      end
    end 
  end
end
