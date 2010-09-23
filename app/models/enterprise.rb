class Enterprise < CcomObject
  has_one :controlled_site, :class_name => "Site", :xml_element => "ControlledSite"

#  def self.parse_xml(entity_node)
#    entity = super(entity_node)
#    if site_entity = entity_node.mimosa_xpath("./controlledSite").first
#      entity.controlled_site = Site.parse_xml(site_entity)
#      entity.save
#    end
#    entity
#  end
  
  def dup_entity (options = {})
    entity = super(options)
    entity.controlled_site = self.controlled_site.dup_entity(options) if controlled_site
    entity.save
    return entity
  end
  
  def build_xml(builder)
    super(builder)
    builder.ControlledSite { |b| self.controlled_site.build_xml(b) } if controlled_site
  end

end
