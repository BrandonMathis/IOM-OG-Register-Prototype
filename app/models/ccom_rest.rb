class CcomRest
  def self.error_xml(message = {})
    opts = { :indent => 2 }
    builder = Builder::XmlMarkup.new(opts)
    builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    builder.CCOMError do
      builder.method message[:method]
      builder.errorMessage message[:errorMessage]
      builder.arguments do
        builder.CCOMEntity message[:entity]
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
end