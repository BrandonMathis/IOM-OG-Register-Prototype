class CcomData

  def self.from_xml(xml)
    doc = Nokogiri::XML.parse(xml)
    returning [] do |entities|
      doc.mimosa_xpath("/CCOMData").children.reject { |c| c.blank? }.each do |entity_node|
        RAILS_DEFAULT_LOGGER.debug("#{entity_node.attribute("type")}")
        entities << entity_node.attribute("type").to_s.constantize.parse_xml(entity_node)
      end
    end
  end
end
