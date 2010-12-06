class Site < CcomObject
  has_one :equivalent_segment, :class_name => "Segment", :xml_element => "EquivalentSegment"
  
  # Will give the CCOM XML name of Site 
  def self.xml_entity_name; "ControlledSite" end
    
  # XML builder for Site (called by to_xml)
  def build_xml(builder)
    super(builder)
    builder.EquivalentSegment {|b| equivalent_segment.build_xml(b) } if equivalent_segment
  end
  
  # Will duplicate the Site and all related entities
  def dup_entity(options = {})
    entity = super(options)
    entity.equivalent_segment = self.equivalent_segment.dup_entity(options) if equivalent_segment
    entity.save
    return entity
  end
end
