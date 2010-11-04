class CcomData  
  def self.from_xml(xml)
    entities = []
    doc = Nokogiri::XML.parse(xml)
    doc.mimosa_xpath("/CCOMData").children.reject { |c| c.blank? }.each do |entity_node|
      entity_guid = entity_node.mimosa_xpath("./GUID").first.content
      raise Exceptions::GuidExsists.new(entity_guid) if CcomEntity.find_by_guid(entity_guid)
      entities << entity_node.attribute("type").to_s.constantize.parse_xml(entity_node)
    end
    return entities
  end
end
