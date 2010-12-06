class Network < CcomObjectWithChildren
  has_many :entry_edges, :class_name => "NetworkConnection", :xml_element => "EntryEdge"
  
  # Will destroy the Network and all related entities
  def destroy
    entry_edges.each {|edge| NetworkConnection.find_by_guid(edge.guid).destroy if edge && NetworkConnection.find_by_guid(edge.guid)}
    super
  end
  
  # Will duplicated the Network and all related entities
  def dup_entity(options ={})
    entity = super(options)
    entry_edges.each {|edge| entity.entry_edges << edge.dup_entity(options) if edge}
    entity.save
    return entity
  end
  
  # XML builder for Network (called from to_xml)
  def build_xml(builder)
    super(builder)
    entry_edges.each do |e|
      builder.EntryEdge do |b|
        e.build_xml(b)
      end
    end
  end
end
