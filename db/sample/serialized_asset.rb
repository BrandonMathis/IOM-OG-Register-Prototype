type = Type.create(:g_u_i_d => "52784296-96ee-47cf-800e-fcaac749d5a7",
                                :i_d_in_info_source => "0000000000000000.0.737",
                                :tag => "Motor, AC, Induction",
                                :name => "Motor, AC, Induction",
                                :statuc_code => "1")
manufacturer = Manufacturer.create(:g_u_i_d => "e3c200b5-99a0-4387-878a-be551894593d",
                                   :tag => "GreatParts.com",
                                   :name => "Great Parts Inc.")
model = Model.create(:g_u_i_d => "e3c200b5-99a0-4387-878a-be551894593e",
                     :tag => "Z400-A1",
                     :name => "Z400-A1",
                     :product_family => "Z400",
                     :product_family_member => "A",
                     :product_family_member_revision => "1",
                     :part_number => "304823401-3442")
asset = Asset.create(:g_u_i_d => "df3cb180-e410-11de-8a39-0800200c9a66", 
                     :i_d_in_info_source => "0000083500000001.1", 
                     :tag => "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor", 
                     :name => "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor", 
                     :last_edited => "2004-02-06T18:00:00Z", 
                     :status => "1",
                     :type => type,
                     :manufacturer => manufacturer,
                     :model => model,
                     :serial_number => "3Z84G32AA0-4")

voltage_type = Type.create(:g_u_i_d => "08e90d6e-59c9-4560-95ad-838162b8ce77",
                                 :i_d_in_info_source => "0000000000000000.0.11",
                                 :source => "www.mimosa.org/CRIS/V3-3/meas_loc_type",
                                 :tag => "Voltage", :name => "Voltage",
                                 :last_edited => "2000-03-27T12:00:00.000000000",
                                 :status => "1")
arm_volt_rated = AttributeType.create(:g_u_i_d => "c542ee51-2697-4564-b8fb-e68b89162970",
                                      :i_d_in_info_source => "0000000000000000.1.523",
                                      :tag => "Armature Voltage, Rated")
volts = EngUnitType.create(:g_u_i_d => "67284a42-b3a6-40e5-b06b-5d662d4a909e",
                           :i_d_in_info_source => "0000000000000000.0.243",
                           :tag => "Volts")
vlt_rat = MeasLocation.create(:g_u_i_d => "7dcc3260-912f-456e-b370-749489ec43cc",
                              :tag => "VLT-RAT", :name => "Voltage, Rated",
                              :object_data => [ObjectDatum.create(:g_u_i_d => "c542ee51-2697-4564-b8fb-e68b89162294",
                                                                  :data => "2300",
                                                                  :attribute_type => arm_volt_rated,
                                                                  :eng_unit_type => volts)],
                              :type => voltage_type,
                              :default_eng_unit_type => volts)

data_sheet_group = Type.create(:g_u_i_d => "a62a6cdb-ca56-4b2b-90aa-fafac73bbb7d",
                                     :tag => "Data Sheet Group", :name => "Data Sheet Group")
elec_spec = Segment.create(:g_u_i_d => "0c893aff-b524-41e7-b919-2ec279532f5f",
                           :tag => "ELEC SPEC", :name => "Electrical Specifications",
                           :type => data_sheet_group,
                           :meas_locations => [vlt_rat])

vibration = Type.create(:g_u_i_d => "7dcc3260-912f-456e-b370-749489ec43cd",
                              :name => "Vibration, Absolute, Casing, Broadband")
data_type = AttributeType.create(:g_u_i_d => "6030c834-f62b-436f-a534-a83a6b631943", :tag => "Data Type")
hi_spd_buffer = AttributeType.create(:g_u_i_d => "7499d276-f801-46cf-97a9-88278e5f4151",
                                     :tag => "High Speed Buffer Data Poll Rate")
seconds = EngUnitType.create(:g_u_i_d => "7499d276-f801-46cf-97a9-88278e5f4151",
                             :i_d_in_info_source => "0000000000000000.0.30",
                             :tag => "Seconds", :name => "Seconds")
hist_aggr_rate = AttributeType.create(:g_u_i_d => "78b69ed6-6b1e-4673-9ff2-78068f254790",
                                      :name => "Engineering Data Historian Aggregation Rate")
mil_per_sec = EngUnitType.create(:g_u_i_d => "7dcc3260-912f-456e-b370-749489ec43cc",
                                 :tag => "mm/sec", :name => "Millimeters Per Second")
meas2 = MeasLocation.create(:g_u_i_d => "7dcc3260-912f-456e-b370-749489ec43cb",
                            :tag => "CAS-DRE-VIB-ABS-VERT-VEL-MMS",
                            :name => "Drive End Velocity Vertical",
                            :type => vibration,
                            :object_data => [ObjectDatum.create(:g_u_i_d => "c542ee51-2697-4564-b8fb-e68b89162295",
                                                                :data => "Real",
                                                                :attribute_type => data_type),
                                            ObjectDatum.create(:g_u_i_d => "c542ee51-2697-4564-b8fb-e68b89162296",
                                                               :data => "1",
                                                               :attribute_type => hi_spd_buffer,
                                                               :eng_unit_type => seconds),
                                            ObjectDatum.create(:g_u_i_d => "c542ee51-2697-4564-b8fb-e68b89162297",
                                                               :data => "1",
                                                               :attribute_type => hist_aggr_rate,
                                                               :eng_unit_type => seconds)],
                            :default_eng_unit_type => mil_per_sec)

vib_rec_req = Segment.create(:g_u_i_d => "0c893aff-b524-41e7-b919-2ec279532f8f",
                             :tag => "VIB REC REQ", 
                             :name => "Recommended Casing Vibration Monitoring Requirements",
                             :meas_locations => [meas2])

asset.entry_edges = [NetworkConnection.create(:source => elec_spec, :targets => vib_rec_req)]
asset.save
