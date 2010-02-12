class Event < CcomObjectWithEventsAndAuditing
  has_one :for, :class_name => CcomObjectWithEvents
  has_one :monitored_object

  private
  
  def xml_entity_name_override; ""; end

  def build_xml(builder)
    super(builder)
    builder.tag!("ofObjectType") { |b| object_type.build_xml(b) } if object_type
    builder.tag!("forCCOMObjectWithEvents", "xsi:type" => self.for.class.to_s) { |b| self.for.build_xml(b) } if self.for
    builder.tag!("hasMonitoredObject", "xsi:type" => self.monitored_object.class.to_s) { |b| self.monitored_object.build_xml(b) } if monitored_object
  end
end
