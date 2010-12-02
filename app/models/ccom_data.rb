class CcomData
  
  # Will clear all collections from the current CCOM Mongo database
  def self.drop_all_collections
    Mongoid.drop_all_collections
  end
  
  # Will parse a given XML and enter all CCOM Entities into
  # the CCOM Database. XML is given in basic textual form
  # and must validate against the CCOM XML Schema to be properly
  # parsed into the database
  def self.from_xml(xml, options = { })
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
