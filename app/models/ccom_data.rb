class CcomData

  def self.from_xml(xml)
    doc = Nokogiri::XML.parse(xml)
    returning [] do |entities|
      doc.mimosa_xpath("/CCOMData").children.reject { |c| c.blank? }.each do |entity_node|
        entities << entity_node.name.constantize.parse_xml(entity_node)
      end
    end
  end
end
