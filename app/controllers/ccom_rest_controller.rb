class CcomRestController < ApplicationController
  def index(entities = {})
    @entities = entities
    logger.debug("#{@entities}")
    render :file => "/ccom_rest/index.xml.builder"
  end
end
