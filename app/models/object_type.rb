class ObjectType < BaseTypeEntity
  has_one :info_collection

  def self.install_event
    install_event = first(:conditions => { :guid => "cd0e974d-7f11-4f3d-91a5-903138e75c76" })
    install_event ||= create!(:guid => "cd0e974d-7f11-4f3d-91a5-903138e75c76",
                              :id_in_source => "0000040500000001.1.1",
                              :source_id => "www.mimosa.org/CRIS/V3-3/sg_as_event_type",
                              :cris_entity_type_id => "29",
                              :user_tag => "Install Event",
                              :user_name => "Install Event",
                              :utc_last_updated => "2006-10-15T18:00:00.000000000",
                              :status_code => "1")
  end

  def self.remove_event
    remove_event = first(:conditions => { :guid => "cd0e974d-7f11-4f3d-91a5-903138e75c77" })
    remove_event ||= create!(:guid => "cd0e974d-7f11-4f3d-91a5-903138e75c77",
                              :id_in_source => "0000040500000001.1.1",
                              :source_id => "www.mimosa.org/CRIS/V3-3/sg_as_event_type",
                              :cris_entity_type_id => "29",
                              :user_tag => "Remove Event",
                              :user_name => "Remove Event",
                              :utc_last_updated => "2006-10-15T18:00:00.000000000",
                              :status_code => "1")
  end
end
