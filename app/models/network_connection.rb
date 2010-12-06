class NetworkConnection < CcomObject
  has_one :source, :class_name => "Segment", :xml_element => "FromEntity"
  has_one :target, :class_name => "Segment", :xml_element => "ToEntity"
  has_many :successors, :class_name => "NetworkConnection", :xml_element => "Successor"
  
  field :order
  
  # Gives the CCOM XML name for NetworkConnection
  def self.xml_entity_name; "EntryEdge" end
  
  # Defines that order is added to NetworkConnection fields
  def self.field_names; super + [:order] end
  
  # Defines that order is added to NetworkConnection attributes
  def self.attribute_names; super + [:order] end
  
  # Will destroy the NetworkConnection and all related entities
  def destroy
    Segment.find_by_guid(source.guid).destroy if source && Segment.find_by_guid(source.guid)
    Segment.find_by_guid(target.guid).destroy if target && Segment.find_by_guid(target.guid)
    successors.each {|successor| NetworkConnection.find_by_guid(successor.guid).destroy if successor}
    super
  end
  
  # Will duplicated NetworkConnection and all related entities
  def dup_entity(options = {})
    entity = super(options)
    entity.source = self.source.dup_entity(options) if source
    entity.target = self.target.dup_entity(options) if target
    successors.each {|s| entity.successors << s.dup_entity(options) if s}
    entity.save
    return entity
  end
  
  # XML builder for NetworkConnection (called by to_xml)
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
