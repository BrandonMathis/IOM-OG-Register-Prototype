class Network < CcomObjectWithChildren
  has_many :entry_edges, :class_name => "NetworkConnection", :xml_element => "EntryEdge"

  def build_xml(builder)
    super(builder)
    entry_edges.each do |e|
      builder.EntryEdge do |b|
        e.build_xml(b)
      end
    end
  end
end
