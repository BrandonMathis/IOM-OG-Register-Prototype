class Enterprise < CcomObject
  has_one :controlled_site, :class_name => "Site", :xml_element => "ControlledSite"
  
  # Will duplicate the Enterprise and all related etities
  def dup_entity (options = {})
    entity = super(options)
    entity.controlled_site = self.controlled_site.dup_entity(options) if controlled_site
    entity.save
    return entity
  end
  
  # XML builder for Enterprise (called by to_xml)
  def build_xml(builder)
    super(builder)
    builder.ControlledSite { |b| self.controlled_site.build_xml(b) } if controlled_site
  end

end
