class NetworkConnection < CcomObject
  has_one :source, :class_name => "CcomObjectWithEvents"
  field :ordering_seq, :type => Integer

  def build_xml(builder)
    super(builder)
    if source
      builder.tag!(:source, "xsi:type" => self.source.class.to_s)
    end
  end
end
