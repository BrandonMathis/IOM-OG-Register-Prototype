require 'test_helper'

class CcomEntityTest < ActiveSupport::TestCase
  
  should "be valid from factory" do
    assert_valid Factory.create(:ccom_entity)
  end

  should "allow setting utc last updated" do
    assert_valid Factory.create(:ccom_entity, :last_edited => Time.now.utc)
  end

  context "a new ccom entity with a blank guid" do
    setup { @ccom_entity = Factory.build(:ccom_entity, :g_u_i_d => nil) }
    
    should "have a blank guid" do
      assert @ccom_entity.g_u_i_d.blank?, "'#{@ccom_entity.g_u_i_d}' isn't blank"
    end
    
    context "after saving" do
      setup do
        @uuid = "06E6B974-5657-4A2C-A0D0-B0FBB8DF4DDA"
        flexmock(UUID).should_receive(:generate).returns(@uuid).once
        @ccom_entity.save
      end

      should "have the generated guid" do
        assert_equal @uuid, @ccom_entity.g_u_i_d
      end
    end
  end

  should "find by guid" do
    entity = Factory.create(:ccom_entity)
    assert_not_nil found = CcomEntity.find_by_guid(entity.g_u_i_d)
    assert_equal found, entity
  end

  context "to xml" do
    setup do
      @ccom_entity = Factory.create(:ccom_entity, 
                                    :i_d_in_info_source => "0000000000000000.1.125",
                                    :name => "Vibration, Absolute, Casing, Broadband")
      @xml = @ccom_entity.to_xml
      @doc = Nokogiri::XML.parse(@xml)
    end

    should "generate the proper root node" do
      assert_equal "CCOMData", @doc.root.name
    end

    should "include id in source" do
      xpath = "/CCOMData/Entity[@*='CCOMEntity']/IDInInfoSource"
      node_set = @doc.xpath(xpath.to_mimosa, mimosa_xmlns)
      assert_not_nil node_set.first, "#{xpath}\n#{@xml.inspect}\n#{@doc.inspect}"
#      assert_equal @ccom_entity.id_in_source, 
    end

    should "not include status code when it's blank" do
      node_set = @doc.xpath("//Entity[@*='CCOMEntity']/statusCode", mimosa_xmlns)
      assert node_set.blank?, node_set.inspect
    end
  end

  context "importing xml for an existing entity" do
    setup do
      @entity = Factory.create(:ccom_entity)
      @xml = @entity.to_xml
      @parsed_entity = CcomEntity.from_xml(@xml)
    end
    should "be the same document" do
      assert_equal @entity, @parsed_entity
    end
  end

  context "importing xml for a new entity" do
    setup do
      @entity = Factory.create(:ccom_entity, :tag => "foobar")
      @guid = @entity.g_u_i_d = UUID.generate
      @xml = @entity.to_xml
      @parsed_entity = CcomEntity.from_xml(@xml)
    end

    should "have the right details" do
      [:g_u_i_d, :tag].each do |attr|
        assert_equal @entity.send(attr), @parsed_entity.send(attr)
      end
    end
  end

  context "importing xml for has_many relationship" do
    setup do
      @meas_location = Factory.create(:meas_location)
      @entity = Factory.create(:segment, :meas_locations => [@meas_location])
      @entity.g_u_i_d = UUID.generate
      @parsed_entity = Segment.from_xml(@entity.to_xml)
    end
    should "have an installed asset" do
      assert @parsed_entity.meas_locations.include?(@meas_location)
    end

  end
  
  context "duplicating an asset data sheet with multiple children" do
    setup do
      @entity1 = Factory.create(:valid_network,
                    :network => Factory.create(:network,
                        :object_type => Factory.create(:object_type),
                        :entry_edges =>[
                          Factory.create(:network_connection,
                            :source => Factory.create(:segment,
                              :object_type => Factory.create(:object_type),
                              :meas_locations => [
                                Factory.create(:meas_location,
                                  :default_eng_unit_type => Factory.create(:eng_unit_type),
                                  :object_data => [
                                    Factory.create(:object_datum,
                                      :attribute_type => Factory.create(:object_type),
                                      :eng_unit_type => Factory.create(:eng_unit_type)
                                    )
                                  ]
                                )
                              ]
                            ),
                            :target => Factory.create(:segment)
                          )
                        ]
                    )
                 )
      @entity2 = @entity1.dup_entity
    end
    should "all children should contain identical guids" do
      assert_equal @entity1.network.guid, @entity2.network.guid
      assert_equal @entity1.network.entry_edges.first.guid, @entity2.network.entry_edges.first.guid
      assert_equal @entity1.network.entry_edges.first.source.guid , @entity2.network.entry_edges.first.source.guid
      assert_equal @entity1.network.entry_edges.first.source.meas_locations.first.guid , @entity2.network.entry_edges.first.source.meas_locations.first.guid
      assert_equal @entity1.network.entry_edges.first.source.meas_locations.first.object_data.first.guid , @entity2.network.entry_edges.first.source.meas_locations.first.object_data.first.guid
      
      assert_equal @entity1.network.object_type.guid , @entity2.network.object_type.guid
      assert_equal @entity1.network.entry_edges.first.source.object_type.guid , @entity2.network.entry_edges.first.source.object_type.guid
      assert_equal @entity1.network.entry_edges.first.source.meas_locations.first.default_eng_unit_type.guid , @entity2.network.entry_edges.first.source.meas_locations.first.default_eng_unit_type.guid
      assert_equal @entity1.network.entry_edges.first.source.meas_locations.first.object_data.first.eng_unit_type.guid , @entity2.network.entry_edges.first.source.meas_locations.first.object_data.first.eng_unit_type.guid
    end
    should "contain data" do
      assert @entity1.network.entry_edges.first.source.meas_locations.first.object_data.first.data
    end
    should "be unique objects" do
      assert_not_equal @entity1.network , @entity2.network
      assert_not_equal @entity1.network.entry_edges.first , @entity2.network.entry_edges.first
      assert_not_equal @entity1.network.entry_edges.first.source , @entity2.network.entry_edges.first.source
      assert_not_equal @entity1.network.entry_edges.first.source.meas_locations.first , @entity2.network.entry_edges.first.source.meas_locations.first
      assert_not_equal @entity1.network.entry_edges.first.source.meas_locations.first.object_data.first , @entity2.network.entry_edges.first.source.meas_locations.first.object_data.first
    end
    context "with gen_new_guids option given as true" do
      setup do
        @entity2 = @entity1.dup_entity(:gen_new_guids => true)
      end
      should "give all children unique guids" do
        assert_not_equal @entity1.network.guid , @entity2.network.guid
        assert_not_equal @entity1.network.entry_edges.first.guid , @entity2.network.entry_edges.first.guid
        assert_not_equal @entity1.network.entry_edges.first.source.guid , @entity2.network.entry_edges.first.source.guid
        assert_not_equal @entity1.network.entry_edges.first.source.meas_locations.first.guid , @entity2.network.entry_edges.first.source.meas_locations.first.guid
        assert_not_equal @entity1.network.entry_edges.first.source.meas_locations.first.object_data.first.guid , @entity2.network.entry_edges.first.source.meas_locations.first.object_data.first.guid
      end
      should "not set new GUIDs for type, unit type, and default unit type" do
        assert_equal @entity1.network.object_type.guid, @entity2.network.object_type.guid
        assert_equal @entity1.network.entry_edges.first.source.object_type.guid, @entity2.network.entry_edges.first.source.object_type.guid
        assert_equal @entity1.network.entry_edges.first.source.meas_locations.first.default_eng_unit_type.guid, @entity2.network.entry_edges.first.source.meas_locations.first.default_eng_unit_type.guid
        assert_equal @entity1.network.entry_edges.first.source.meas_locations.first.object_data.first.eng_unit_type.guid, @entity2.network.entry_edges.first.source.meas_locations.first.object_data.first.eng_unit_type.guid
      end
    end
  end
end