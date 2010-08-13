class Type < BaseTypeEntity
  has_one :info_collection

  def self.install_event
    install_event = first(:conditions => { :g_u_i_d => "cd0e974d-7f11-4f3d-91a5-903138e75c76" })
    install_event ||= create!(:g_u_i_d => "cd0e974d-7f11-4f3d-91a5-903138e75c76",
                              :i_d_in_info_source => "0000040500000001.1.1",
                              :source_id => "www.mimosa.org/CRIS/V3-3/sg_as_event_type",
                              :cris_entity_type_id => "29",
                              :tag => "Install Event",
                              :name => "Install Event",
                              :last_edited => "2006-10-15T18:00:00.000000000",
                              :status => "1")
  end

  def self.remove_event
    remove_event = first(:conditions => { :g_u_i_d => "cd0e974d-7f11-4f3d-91a5-903138e75c77" })
    remove_event ||= create!(:g_u_i_d => "cd0e974d-7f11-4f3d-91a5-903138e75c77",
                              :i_d_in_info_source => "0000040500000001.1.1",
                              :source_id => "www.mimosa.org/CRIS/V3-3/sg_as_event_type",
                              :cris_entity_type_id => "29",
                              :tag => "Remove Event",
                              :name => "Remove Event",
                              :last_edited => "2006-10-15T18:00:00.000000000",
                              :status => "1")
  end
end
