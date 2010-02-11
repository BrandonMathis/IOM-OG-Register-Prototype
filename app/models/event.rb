class Event < CcomObjectWithEventsAndAuditing
  has_one :for, :class_name => CcomObjectWithEvents
  has_one :monitored_object

  private
  
  def xml_entity_name_override; ""; end

end
