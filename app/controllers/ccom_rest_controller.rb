class CcomRestController < ApplicationController
  before_filter :hijack_db
  
  def hijack_db
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(CCOM_DATABASE)
  end
  
  protect_from_forgery :only => []
  
  def index(entities = {})
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
        format.xml {render :xml =>CcomRest.error_xml({:url => request.url, :http_code => "404", :method => "GET", :error_code => "Mimosa3", :error_message => CcomRest::MIMOSA3_404}), :status => 404 }
      end
    end      
  end
  
  def create        
    render_this = CcomRest.construct_from_xml(request)
    render render_this
  end
  
  def update
    if entity = CcomEntity.find_by_guid(params[:id])
      response.etag = entity.last_edited
      if request.fresh?(response)
        render_this = CcomRest.construct_from_xml(request)
      else
        render_this = { :xml => CcomRest.error_xml({:url => request.url, :http_code => "412", :client_etag =>response.etag, :server_etag => request.if_none_match, :method => "PUT", :error_code => "Mimosa1", :error_message => CcomRest::MIMOSA1_412}), :status => 412 }
      end
    else
      render_this = { :xml => CcomRest.error_xml({:url => request.url, :http_code => "404", :method => "PUT", :error_code => "Mimosa1", :error_message => CcomRest::MIMOSA1_404}), :status => 404}
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
        format.xml { render :xml => CcomRest.error_xml({:url => request.url, :http_code => "404", :method => "DELETE", :error_code => "Mimosa3", :error_message => CcomRest::MIMOSA3_404}), :status => 404 }
      end
    end      
  end
  protected
  def authorize
  end
end