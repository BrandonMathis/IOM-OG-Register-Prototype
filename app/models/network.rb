class Network < CcomObjectWithChildren
  has_many :entry_points, :class_name => "NetworkConnection", :xml_element => "hasEntryPoint"

  def build_xml(builder)
    super(builder)
    entry_points.each do |e|
      builder.hasEntryPoint do |b|
        e.build_xml(b)
      end
    end
  end
end
