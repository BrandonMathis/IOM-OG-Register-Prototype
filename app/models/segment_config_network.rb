class SegmentConfigNetwork < CcomObject
  has_one :network, :class_name => "Network", :xml_element => "Network"
  
  def dup_entity(options = {})
    entity = super(entity)
    entity.network = self.network.dup_entity(options) if network
    entity.save
    return entity    
  end
  
end
