puts Event.new(:g_u_i_d => "251ff520-e40e-11de-8a39-0800200c9a36",
               :tag => "[2010-02-10 13:21:00] Motor installed on 01G-7A",
               :name => "[2010-02-10 13:21:00] Asset: Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor installed on Functional Location: 01G-7A Motor ",
               :last_edited => "2009-07-03T13:30:00",
               :status => "1",
               :type => Type.new(:g_u_i_d => "cd0e974d-7f11-4f3d-91a5-903138e75c76",
                                              :i_d_in_info_source => "0000040500000001.1.1",
                                              :source_id => "www.mimosa.org/CRIS/V3-3/sg_as_event_type",
                                              :cris_entity_type_id => "29",
                                              :tag => "Install Event",
                                              :name => "Install Event",
                                              :last_edited => "2006-10-15T18:00:00.000000000",
                                              :status => "1",
                                              :info_collection => InfoCollection.new(:g_u_i_d => "cd0e974d-7f11-4f3d-91a5-903138e75c76",
                                                                                     :i_d_in_info_source => "0000040500000001.1",
                                                                                     :source_id => "site_database")),
               :for => Segment.new(:g_u_i_d => "abcf6703-4d26-4f0b-8f0e-c4d704da514a",
                                   :tag => "01G-7A Motor",
                                   :name => "01G-7A Motor"),
               :monitored_object => Asset.new(:g_u_i_d => "df3cb180-e410-11de-8a39-0800200c9a66",
                                              :i_d_in_info_source => "0000083500000001.1",
                                              :source_id => "greatparts.com/partslib/V1.0",
                                              :tag => "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor",
                                              :name => "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor"),
               :utc_start => "2010-02-10T13:21:00",
               :utc_end => "2010-02-10T13:21:00",
               :utc_recorded => "2010-02-10T14:40:00").to_xml(:indent => 2)
