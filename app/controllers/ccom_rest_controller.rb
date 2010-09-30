class CcomRestController < ApplicationController
  def index(entities = {})
    @entities = entities
    logger.debug("#{@entities}")
    render :file => "/ccom_rest/index.xml.builder"
  end
  def create
    respond_to do |format|
      if (entities = CcomData.from_xml(request.body.read))
        format.xml { render :xml => entities, :status => :created }
      else
        format.xml {render :xml =>CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given Asset XML is invalid", :xml => request.body.read}), :status => 500 }
      end
    end 
  end
end
