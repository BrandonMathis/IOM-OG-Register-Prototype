class CcomRest
  MIMOSA1_404 = "Could not find CCOM Entity"
  MIMOSA2_404 = "Could not find requested CCOM Entity with given query"
  MIMOSA3_404 = "Could not find requested CCOM Entity with given GUID"
  
  MIMOSA1_400 = ""
  MIMOSA2_400 = "Given Query has improper syntax"
  MIMOSA3_400 = "Given XML contains an invalid value for GUID"
  MIMOSA4_400 = "Given XML is invalid"
  MIMOSA5_400 = "GUID in give XML already exsists in database. GUID: "
  
  MIMOSA1_412 = "Given ETag is not longer valid"
  
  def self.error_xml(xml)
    opts = { :indent => 2 }
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    builder.APIError do
      builder.URL xml[:url]
      builder.HTTPMethod xml[:method]
      builder.HTTPError xml[:http_code]
      builder.ClientEtag xml[:client_etag] if xml[:client_etag]
      builder.ServerEtag xml[:server_etag] if xml[:server_etag]
      builder.ErrorCode xml[:error_code]
      builder.ErrorMessage xml[:error_message]
      builder.ErrorText xml[:error_text] if xml[:error_text]
    end
  end
  
  def self.build_entities(entities)
    opts = { :indent => 2 }
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    xml = builder.tag!("CCOMData", CcomEntity.xml_entity_attributes) do |b|
      entities.each do |entity|
        entity.build_entity(b)
      end
    end
  end
  
  def self.construct_from_xml(request)
    begin
      entities = CcomData.from_xml(request.body.read) if request.post?
      entities = CcomData.from_xml(request.body.read, {:edit => true}) if request.put?
    rescue Exceptions::BadGuid
      to_render = { :status => 400, :xml => CcomRest.error_xml({:url => request.url, :http_code => "400", :method => "POST", :error_code => "Mimosa3", :error_message => CcomRest::MIMOSA3_400})}
    rescue Exceptions::GuidExsists => msg
      to_render = { :status => 400, :xml => CcomRest.error_xml({:url => request.url, :http_code => "400", :method => "POST", :error_code => "Mimosa5", :error_message => CcomRest::MIMOSA5_400 + msg.message})}
    else
      if entities.blank?
        to_render = { :status => 400, :xml => CcomRest.error_xml({:http_code => "400", :method => "POST", :error_code => "Mimosa4", :error_message => CcomRest::MIMOSA4_400})}
      else
        to_render = { :status => 201, :xml => CcomRest.build_entities(entities) }
      end
    end
  end
end