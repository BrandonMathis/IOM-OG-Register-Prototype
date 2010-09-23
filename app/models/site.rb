class Site < CcomObject
  has_one :equivalent_segment, :class_name => "Segment", :xml_element => "EquivalentSegment"
  
  def dup_entity(options = {})
    entity = super(options)
    entity.equivalent_segment = self.equivalent_segment.dup_entity(options) if equivalent_segment
    entity.save
    return entity
  end
  
end
