class Event < CcomObjectWithEventsAndAuditing
  belongs_to_related :for, :class_name => "CcomObjectWithEvents"
  belongs_to_related :monitored_object

  def initialize(opts = { })
    super(opts)
    self.tag ||= "#{type.tag rescue nil} for #{monitored_object.tag rescue nil} on #{self.for.tag rescue nil}"
  end

  private
  
  def build_xml(builder)
    super(builder)
    builder.Test do
      builder.tag!("forCCOMObjectWithEvents", "xsi:type" => self.for.class.to_s) { |b| self.for.build_xml(b) } if self.for
      builder.tag!("hasMonitoredObject", "xsi:type" => self.monitored_object.class.to_s) { |b| self.monitored_object.build_xml(b) } if monitored_object
    end
  end
end
