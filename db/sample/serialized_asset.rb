object_type = ObjectType.create(:guid => "52784296-96ee-47cf-800e-fcaac749d5a7",
                                :id_in_source => "0000000000000000.0.737",
                                :source_id => "www.mimosa.org/CRIS/V3-3/asset_type",
                                :user_tag => "Motor, AC, Induction",
                                :user_name => "Motor, AC, Induction",
                                :statuc_code => "1")
manufacturer = Manufacturer.create(:guid => "e3c200b5-99a0-4387-878a-be551894593d",
                                   :user_tag => "GreatParts.com",
                                   :user_name => "Great Parts Inc.")
model = Model.create(:guid => "e3c200b5-99a0-4387-878a-be551894593e",
                     :user_tag => "Z400-A1",
                     :user_name => "Z400-A1",
                     :product_family => "Z400",
                     :product_family_member => "A",
                     :product_family_member_revision => "1",
                     :part_number => "304823401-3442")
asset = Asset.create(:guid => "df3cb180-e410-11de-8a39-0800200c9a66", 
                     :id_in_source => "0000083500000001.1", 
                     :source_id => "greatparts.com/partslib/V1.0", 
                     :user_tag => "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor", 
                     :user_name => "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor", 
                     :utc_last_updated => "2004-02-06T18:00:00Z", 
                     :status_code => "1",
                     :object_type => object_type,
                     :manufacturer => manufacturer,
                     :model => model,
                     :serial_number => "3Z84G32AA0-4")

voltage_type = ObjectType.create(:guid => "08e90d6e-59c9-4560-95ad-838162b8ce77",
                                 :id_in_source => "0000000000000000.0.11",
                                 :source => "www.mimosa.org/CRIS/V3-3/meas_loc_type",
                                 :user_tag => "Voltage", :user_name => "Voltage",
                                 :utc_last_updated => "2000-03-27T12:00:00.000000000",
                                 :status_code => "1")
arm_volt_rated = AttributeType.create(:guid => "c542ee51-2697-4564-b8fb-e68b89162970",
                                      :id_in_source => "0000000000000000.1.523",
                                      :source_id => "www.mimosa.org/CRIS/V3-3/as_num_dat_type",
                                      :user_tag => "Armature Voltage, Rated")
volts = EngUnitType.create(:guid => "67284a42-b3a6-40e5-b06b-5d662d4a909e",
                           :id_in_source => "0000000000000000.0.243",
                           :source_id => "www.mimosa.org/CRIS/V3-3/eng_unit_type",
                           :user_tag => "Volts")
vlt_rat = MeasLocation.create(:guid => "7dcc3260-912f-456e-b370-749489ec43cc",
                              :source_id => "greatparts.com/partslib/V1.0",
                              :user_tag => "VLT-RAT", :user_name => "Voltage, Rated",
                              :object_data => [ObjectDatum.create(:guid => "c542ee51-2697-4564-b8fb-e68b89162294",
                                                                  :data => "2300",
                                                                  :attribute_type => arm_volt_rated,
                                                                  :eng_unit_type => volts)],
                              :object_type => voltage_type,
                              :default_eng_unit_type => volts)

data_sheet_group = ObjectType.create(:guid => "a62a6cdb-ca56-4b2b-90aa-fafac73bbb7d",
                                     :user_tag => "Data Sheet Group", :user_name => "Data Sheet Group")
elec_spec = Segment.create(:guid => "0c893aff-b524-41e7-b919-2ec279532f5f",
                           :source_id => "greatparts.com/partslib/V1.0",
                           :user_tag => "ELEC SPEC", :user_name => "Electrical Specifications",
                           :object_type => data_sheet_group,
                           :meas_locations => [vlt_rat])

vibration = ObjectType.create(:guid => "7dcc3260-912f-456e-b370-749489ec43cd",
                              :user_name => "Vibration, Absolute, Casing, Broadband")
data_type = AttributeType.create(:guid => "6030c834-f62b-436f-a534-a83a6b631943", :user_tag => "Data Type")
hi_spd_buffer = AttributeType.create(:guid => "7499d276-f801-46cf-97a9-88278e5f4151",
                                     :user_tag => "High Speed Buffer Data Poll Rate")
seconds = EngUnitType.create(:guid => "7499d276-f801-46cf-97a9-88278e5f4151",
                             :id_in_source => "0000000000000000.0.30",
                             :source_id => "www.mimosa.org/CRIS/V3-3/eng_unit_type",
                             :user_tag => "Seconds", :user_name => "Seconds")
hist_aggr_rate = AttributeType.create(:guid => "78b69ed6-6b1e-4673-9ff2-78068f254790",
                                      :user_name => "Engineering Data Historian Aggregation Rate")
mil_per_sec = EngUnitType.create(:guid => "7dcc3260-912f-456e-b370-749489ec43cc",
                                 :user_tag => "mm/sec", :user_name => "Millimeters Per Second")
meas2 = MeasLocation.create(:guid => "7dcc3260-912f-456e-b370-749489ec43cb",
                            :source_id => "greatparts.com/partslib/V1.0",
                            :user_tag => "CAS-DRE-VIB-ABS-VERT-VEL-MMS",
                            :user_name => "Drive End Velocity Vertical",
                            :object_type => vibration,
                            :object_data => [ObjectDatum.create(:guid => "c542ee51-2697-4564-b8fb-e68b89162295",
                                                                :data => "Real",
                                                                :attribute_type => data_type),
                                            ObjectDatum.create(:guid => "c542ee51-2697-4564-b8fb-e68b89162296",
                                                               :data => "1",
                                                               :attribute_type => hi_spd_buffer,
                                                               :eng_unit_type => seconds),
                                            ObjectDatum.create(:guid => "c542ee51-2697-4564-b8fb-e68b89162297",
                                                               :data => "1",
                                                               :attribute_type => hist_aggr_rate,
                                                               :eng_unit_type => seconds)],
                            :default_eng_unit_type => mil_per_sec)

vib_rec_req = Segment.create(:guid => "0c893aff-b524-41e7-b919-2ec279532f8f",
                             :user_tag => "VIB REC REQ", 
                             :user_name => "Recommended Casing Vibration Monitoring Requirements",
                             :meas_locations => [meas2])

asset.entry_points = [NetworkConnection.create(:source => elec_spec,
                                               :targets => [NetworkConnection.create(:source => vib_rec_req)])]
asset.save
