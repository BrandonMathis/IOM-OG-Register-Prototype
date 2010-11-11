class CcomData
  
  def self.drop_all_collections
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(CCOM_DATABASE)
    Mongoid.drop_all_collections
  end
  
  def self.from_xml(xml, options = { })
    Mongoid.database = Mongo::Connection.new(MONGO_HOST).db(CCOM_DATABASE)
    entities = []
    doc = Nokogiri::XML.parse(xml)
    doc.mimosa_xpath("/CCOMData").children.reject { |c| c.blank? }.each do |entity_node|
      entity_guid = entity_node.mimosa_xpath("./GUID").first.content
      raise Exceptions::GuidExsists.new(entity_guid) if CcomEntity.find_by_guid(entity_guid) && !options[:edit]
      entities << entity_node.attribute("type").to_s.constantize.parse_xml(entity_node)
    end
    return entities
  end
end
