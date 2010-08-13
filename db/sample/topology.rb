# don't run this twice because we'll end up with duplicate documents (particularly object type)
# gee, wouldn't it be nice to have CcomEntity.find_or_create_by_guid?

segment1 = Segment.create!(:g_u_i_d => "515b3eae-93bf-44da-a239-2436ece17deb", :tag => "CU-1")
segment2 = Segment.create!(:g_u_i_d => "abcf6703-4d26-4f0b-8f0e-c4d704da514b", :tag => "01G-7A Kerosene Pump Package")
topology_type = Type.create!(:g_u_i_d => "a62a6cdb-ca56-4b2b-90aa-fafac73caa33", :tag => "Diagram, Topology, P &amp; ID")
target = NetworkConnection.create!(:g_u_i_d => "14e6f9d7-9db0-4208-8fa0-1c247681cfa7", :source => segment2)
ep = NetworkConnection.create!(:g_u_i_d => "27090f1f-1054-49ae-ab07-08c7e7e04ad8", :source => segment1, :targets => [target])

TopologyAsset.create!(:g_u_i_d => "317d6bc3-2e6d-4d80-addb-2f3fcff9e5ff",
                      :tag => "Doc#42432444: Refinery A P &amp; ID Topology V1.0",
                      :type => topology_type,
                      :entry_edge => ep)
motor_asset = Asset.create(:tag => "A super awesome motor")
segment2.installed_assets << motor_asset
puts TopologyAsset.find_by_guid("317d6bc3-2e6d-4d80-addb-2f3fcff9e5ff").entry_edge.source.to_xml
