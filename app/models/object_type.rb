class ObjectType < CcomEntity
  has_one :info_collection
  
  # Defines the CCOM XML name for ObjectType
  def self.xml_entity_name; "Type" end
  
  # Defines the Type for a typical install event and creates one
  # if it does not exist
  def self.install_event
    install_event = first(:conditions => { :g_u_i_d => "ecc99353-412b-4995-bd71-1cbc6fc16c7c" })
    install_event ||= create!(:g_u_i_d => "ecc99353-412b-4995-bd71-1cbc6fc16c7c",
                              :tag => "Installation of Asset on Segment",
                              :name => "Installation of Asset on Segment",
                              :status => "1")
  end
  
  # Defines the Type for a typical remove event and creates one
  # if it does not exist
  def self.remove_event
    remove_event = first(:conditions => { :g_u_i_d => "3a45e126-b234-42a0-b3b1-07c29522d02d" })
    remove_event ||= create!(:g_u_i_d => "3a45e126-b234-42a0-b3b1-07c29522d02d",
                              :tag => "Removal of Asset on Segment",
                              :name => "Removal of Asset on Segment",
                              :status => "1")
  end
  
  # Defines a typeical undetermined Type and creates one
  # if it does not exist
  def self.undetermined
    undetermined = first(:conditions => { :g_u_i_d => "400ebcb3-80f3-4601-b693-49e4232ff797"})
    undetermined ||= create!(:g_u_i_d => "400ebcb3-80f3-4601-b693-49e4232ff797",
                           :tag => "Undetermined",
                           :name => "Undetermined",
                           :status => "1")
  end                     
end