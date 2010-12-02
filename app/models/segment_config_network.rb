class SegmentConfigNetwork < CcomObject
  has_one :network, :class_name => "Network", :xml_element => "Network"
  
  # Will destroy the SegmentConfigNetwork and all related entities
  def destroy
    super
    Network.find_by_guid(network.guid).destroy if network && Network.find_by_guid(network.guid)
  end
  
  # Will duplicated the SegmentConfigNetwork and all related entities
  def dup_entity(options = {})
    entity = super(entity)
    entity.network = self.network.dup_entity(options) if network
    entity.save
    return entity    
  end
  
end
