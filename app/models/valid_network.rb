class ValidNetwork < CcomObject
  has_one :network, :class_name => "Network", :xml_element => "Network"
    
  # Will destroy the ValidNetwork and all associated entities
  def destroy
    Network.find_by_guid(network.guid).destroy if network && Network.find_by_guid(network.guid)
    super
  end
  
  # XML builder for the ValidNetwork (called from to_xml)
  def build_xml(builder)
    super
    builder.Network{|b| network.build_xml(b) } if network
  end
  
  # Will duplicated the ValidNetwork and all assocated entities
  def dup_entity(options = {})
    entity = super(options)
    entity.network = self.network.dup_entity(options) if network
    entity.save
    return entity    
  end
end
