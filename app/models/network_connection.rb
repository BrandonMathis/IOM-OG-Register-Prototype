class NetworkConnection < CcomObject
  has_one :source, :class_name => "Segment", :xml_element => "FromEntity"
  has_one :target, :class_name => "Segment", :xml_element => "ToEntity"
  has_many :successors, :class_name => "NetworkConnection", :xml_element => "Successor"
  
  field :order, :type => Integer
  
  def dup_entity(options = {})
    entity = super(options)
    entity.source = self.source.dup_entity(options) if source
    entity.target = self.target.dup_entity(options) if target
    successors.each {|s| entity.successors << s.dup_entity(options) if s}
    entity.save
    return entity
  end
  
  
  def build_xml(builder)
    super(builder)
    if source
      builder.tag!("FromEntity", "xsi:type" => self.source.class.to_s)
    end
    if target
      builder.tag!("ToEntity", "xsi:type" => self.source.class.to_s)
    end
  end
end
