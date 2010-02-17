# don't run this twice because we'll end up with duplicate documents (particularly object type)
# gee, wouldn't it be nice to have CcomEntity.find_or_create_by_guid?

segment1 = Segment.create!(:guid => "515b3eae-93bf-44da-a239-2436ece17deb", :user_tag => "CU-1")
segment2 = Segment.create!(:guid => "abcf6703-4d26-4f0b-8f0e-c4d704da514b", :user_tag => "01G-7A Kerosene Pump Package")
topology_object_type = ObjectType.create!(:guid => "a62a6cdb-ca56-4b2b-90aa-fafac73caa33", :user_tag => "Diagram, Topology, P &amp; ID")
target = NetworkConnection.create!(:guid => "14e6f9d7-9db0-4208-8fa0-1c247681cfa7", :source => segment2)
ep = NetworkConnection.create!(:guid => "27090f1f-1054-49ae-ab07-08c7e7e04ad8", :source => segment1, :targets => [target])

TopologyAsset.create!(:guid => "317d6bc3-2e6d-4d80-addb-2f3fcff9e5ff",
                      :user_tag => "Doc#42432444: Refinery A P &amp; ID Topology V1.0",
                      :object_type => topology_object_type,
                      :entry_point => ep)

puts TopologyAsset.find_by_guid("317d6bc3-2e6d-4d80-addb-2f3fcff9e5ff").entry_point.source.to_xml
