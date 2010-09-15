class Type < BaseTypeEntity
  has_one :info_collection

  def self.install_event
    install_event = first(:conditions => { :g_u_i_d => "ecc99353-412b-4995-bd71-1cbc6fc16c7c" })
    install_event ||= create!(:g_u_i_d => "ecc99353-412b-4995-bd71-1cbc6fc16c7c",
                              :tag => "Installation of Asset on Segment",
                              :name => "Installation of Asset on Segment",
                              :status => "1")
  end

  def self.remove_event
    remove_event = first(:conditions => { :g_u_i_d => "3a45e126-b234-42a0-b3b1-07c29522d02d" })
    remove_event ||= create!(:g_u_i_d => "3a45e126-b234-42a0-b3b1-07c29522d02d",
                              :tag => "Removal of Asset on Segment",
                              :name => "Removal of Asset on Segment",
                              :status => "1")
  end
  
  def self.undetermined
    undetermined = create!(:g_u_i_d => "400ebcb3-80f3-4601-b693-49e4232ff797",
                           :tag => "Undetermined",
                           :name => "Undetermined",
                           :status => "1")
  end                     
end