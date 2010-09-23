class CcomData  
  def self.from_xml(xml)
    entities = []
    doc = Nokogiri::XML.parse(xml)
    doc.mimosa_xpath("/CCOMData").children.reject { |c| c.blank? }.each do |entity_node|
      entities << entity_node.attribute("type").to_s.constantize.parse_xml(entity_node)
    end
    return entities
  end
end
