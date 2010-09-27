class ValidNetwork < CcomObject
  has_one :network, :class_name => "Network", :xml_element => "Network"
  
  def destroy
    Network.find_by_guid(network.guid).destroy if network
    super
  end
  
  def dup_entity(options = {})
    entity = super(options)
    entity.network = self.network.dup_entity(options) if network
    entity.save
    return entity    
  end
  
end
