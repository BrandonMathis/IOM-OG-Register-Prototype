class ActualEvent < CcomObjectWithEventsAndAuditing
  belongs_to_related :hist, :class_name => "AssetOnSegmentHistory"
  belongs_to_related :monitored_object, :class_name => "Asset"

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
    builder.tag!("EventableEntity", "xsi:type" => self.hist.segment.class.to_s) { |b| self.hist.segment.build_basic_xml(b) } if self.hist && self.hist.segment
    builder.tag!(self.hist.class.to_s) do |b|
      builder.GUID self.hist.g_u_i_d if self.hist && self.hist.g_u_i_d
      builder.Tag self.tag  if self.tag
      builder.LastEdited self.hist.last_edited if self.hist && self.hist.last_edited
      builder.tag!(self.monitored_object.class.to_s) { |b| self.monitored_object.build_basic_xml(b) } if monitored_object
      builder.tag!(self.hist.segment.class.to_s) { |b| self.hist.segment.build_basic_xml(b) } if self.hist && self.hist.segment
      builder.Start self.hist.start if self.hist && self.hist.start
      builder.End self.hist.end if self.hist && self.hist.end
    end
  end
end
