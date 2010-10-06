class NetworkConnection < CcomObject
  has_one :source, :class_name => "Segment", :xml_element => "FromEntity"
  has_one :target, :class_name => "Segment", :xml_element => "ToEntity"
  has_many :successors, :class_name => "NetworkConnection", :xml_element => "Successor"
  
  field :order
  
  def self.field_names
    super + [:order]
  end
  
  def self.attribute_names
    super + [:order]
  end
  
  def destroy
    Segment.find_by_guid(source.guid).destroy if source
    Segment.find_by_guid(target.guid).destroy if target
    successors.each {|successor| NetworkConnection.find_by_guid(successor.guid).destroy if successor}
    super
  end
  
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
    builder.tag!("FromEntity", "xsi:type" => self.source.class.to_s) {|b| source.build_xml(b)} if source
    builder.tag!("ToEntity", "xsi:type" => self.target.class.to_s) {|b| target.build_xml(b)} if target
    successors.each do |s|
      builder.Successor {|b| s.build_xml(b)} if s
    end
    builder.Order order if order
  end
end
