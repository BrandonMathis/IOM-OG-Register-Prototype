class Site < CcomObject
  has_one :equivalent_segment, :class_name => "Segment", :xml_element => "hasEquivalentSegment"
end
