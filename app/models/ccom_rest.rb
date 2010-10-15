class CcomRest
  def self.error_xml(message = {})
    opts = { :indent => 2 }
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    builder.CCOMError do
      builder.method message[:method]
      builder.errorMessage message[:errorMessage]
      builder.arguments do
        builder.CCOMentity message[:entity]
      end
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
  
  def self.construct_from_xml(xml)
    entities = CcomData.from_xml(xml)
  rescue Exceptions::BadGuid
    to_render = { :status => 500, :xml => CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given XML contains an invalid value for GUID", :entity => "CCOMData"})}
  else
    if entities.blank?
      to_render = {:status => 500, :xml => CcomRest.error_xml({:method => "createEntity", :errorMessage => "Given XML is invalid", :entity => "CCOMData"})}
    else
      to_render = { :status => 201, :xml => CcomRest.build_entities(entities) }
    end
  end    
end