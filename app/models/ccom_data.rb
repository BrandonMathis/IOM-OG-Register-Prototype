class CcomData

  def self.from_xml(xml)
    doc = Nokogiri::XML.parse(xml)
    entity_node = doc.mimosa_xpath("/CCOMData").children.reject { |c| c.blank? }.first
    entity_node.name.constantize.parse_xml(entity_node)
  end

end
