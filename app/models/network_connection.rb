class NetworkConnection < CcomObject
  belongs_to_related :source, :class_name => "Segment"
  has_many :targets, :class_name => "NetworkConnection"
  field :ordering_seq, :type => Integer

  def build_xml(builder)
    super(builder)
    if source
      builder.tag!(:source, "xsi:type" => self.source.class.to_s)
    end
  end
end
