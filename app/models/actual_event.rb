class ActualEvent < CcomObjectWithEventsAndAuditing
  belongs_to_related :hist, :class_name => "AssetOnSegmentHistory"
  belongs_to_related :monitored_object

  # Build a Standard Tag, Status and last_edited time for our Event
  # the GUID is automatically generated at save time
  def initialize(opts = { })
    super(opts)
    self.tag ||= "#{object_type.tag rescue nil} for #{monitored_object.tag rescue nil} on #{self.hist.segment.tag rescue nil}"
    self.hist.tag = "#{object_type.tag rescue nil} for #{monitored_object.tag rescue nil} on #{self.hist.segment.tag rescue nil}" if hist
    self.status ||= "1"
    self.last_edited = Time.now.strftime('%Y-%m-%dT%H:%M:%S')    
  end

  private
  
  def build_xml(builder)
    super(builder)
    builder.tag!("EventableEntity", "xsi:type" => self.hist.segment.class.to_s) { |b| self.hist.segment.build_xml(b) } if self.hist && self.hist.segment
    builder.tag!(self.hist.class.to_s) do |b|
      hist.build_xml(builder) if hist
    end
  end
end
