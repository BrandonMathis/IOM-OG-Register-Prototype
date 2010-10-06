require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  should "contain serial number in list of field and attributes" do
    asset = Asset.create()
    assert asset.field_names.include? :serial_number
    assert asset.attribute_names.include? :serial_number
  end
  
  context "The Asset" do
    setup do
      @asset = Factory.create(:asset)
    end
    
    should "be valid from factory" do
      assert_valid @asset
    end
    
    should "have a last edited time" do
      assert_not_nil @asset.last_edited
    end
  end
  
  should "support a serial number" do
    sn = "3Z84G32AA0-4"
    assert_valid asset = Factory.create(:asset, :serial_number => sn)
    assert_equal sn, asset.serial_number
  end

  should "support a manufacturer" do
    manufacturer = Factory.create(:manufacturer)
    assert_valid asset = Factory.create(:asset, :manufacturer => manufacturer)
    assert_equal manufacturer, asset.manufacturer
  end

  should "support a model" do
    model = Factory.create(:model)
    assert_valid asset = Factory.create(:asset, :model => model)
    assert_equal model, asset.model
  end

  should "support an asset config network" do
    valid_network = Factory.create(:valid_network)
    assert_valid asset = Factory.create(:asset, :valid_network => valid_network)
    assert_equal valid_network, asset.valid_network
  end

  
  context "uninstalled assets" do
    setup do
      @segment = Factory.create(:segment)
      @hist = Factory.create(:asset_on_segment_history)
      @installed_asset = Factory.create(:asset, :asset_on_segment_history => @hist)
      @uninstalled_asset = Factory.create(:asset)
      @uninstalled_assets = Asset.uninstalled
    end

    should "not include the installed asset" do
      assert ! @uninstalled_assets.include?(@installed_asset)
    end

    should "include the uninstalled asset" do
      assert @uninstalled_assets.include?(@uninstalled_asset)
    end
  end

  context "creating an asset install history" do
    setup do
      @hist = Factory.create(:asset_on_segment_history)
      @asset = Factory.create(:asset, :asset_on_segment_history => @hist)
    end
    
    should "have the asset installed on the segment" do
      assert_equal @hist, @asset.asset_on_segment_history
    end

    should "have the asset in the list of installed assets on the segment" do
      assert @hist.assets.include?(@asset)
    end
  end

  context "observing segment changes" do
    context "with an asset" do
      setup do
        @asset = Factory.create(:asset)
        @hist = Factory.create(:asset_on_segment_history)
      end

      should "fire an install event when the segment is assigned" do
        flexmock(AssetObserver).should_receive(:install).with(@asset, @hist).once
        @asset.asset_on_segment_history = @hist
        assert @asset.save
      end
    end

    context "with an asset already installed on segment" do
      setup do
        assert @asset_on_segment_history = Factory.create(:asset_on_segment_history)
        @asset = Factory.create(:asset, :asset_on_segment_history => @asset_on_segment_history)
      end

      should "fire a remove event when the segment is set to nil" do
        flexmock(AssetObserver).should_receive(:remove).once
        @asset.asset_on_segment_history = nil
        assert @asset.save
        assert_nil @asset.asset_on_segment_history
      end

      should "fire both a remove and an install event when changing the asset on segment history" do
        @new_hist = Factory.create(:asset_on_segment_history)
        flexmock(AssetObserver).should_receive(:install).with(@asset, @new_hist).once
        flexmock(AssetObserver).should_receive(:remove).with(@asset, @asset_on_segment_history).once
        @asset.asset_on_segment_history = @new_hist
        assert @asset.save
      end
    end
  end

  context "assigning to entry points" do
    setup do
      @entry_edge = Factory.create(:network_connection)
      @asset = Factory.create(:asset, :entry_edges => @entry_edge)
    end
    should "be assigned" do
      assert_equal [@entry_edge], @asset.entry_edges
    end
    should "still be assinged when I reload it" do
      assert_equal [@entry_edge], Asset.find_by_guid(@asset.g_u_i_d).entry_edges
    end
  end

  context "importing xml" do
    setup do
      @serial_number = "12341234123412341"
      @asset = Factory.create(:asset, :serial_number => @serial_number)
      @asset.g_u_i_d = UUID.generate
      @xml = @asset.to_xml
      @parsed_asset = Asset.from_xml(@xml)
    end
    should "parse the serial number too" do
      assert_equal @serial_number, @parsed_asset.serial_number
    end
  end

  context "generating xml" do
    setup do
      @asset = Factory.create(:asset)
      @doc = Nokogiri::XML.parse(@asset.to_xml)
    end

    should "have the proper element name" do
      assert_has_xpath("/CCOMData/Entity[@*='Asset']", @doc)
    end
  end

  context "with both topology asset and serialized asset" do
    setup do
      @topology = Factory.create(:topology_asset)
      @asset = Factory.create(:serialized_asset)
    end

    context "finding serialized assets" do
      setup { @assets = Asset.serialized.all }
      should "not contain the topology" do
        assert ! @assets.include?(@topology)
      end
      should "contain the serialized asset" do
        assert @assets.include?(@asset)
      end
    end

    context "finding topologies" do
      setup do
        @topologies = Asset.topologies.all
      end
      should "not contain the serialized asset" do
        assert ! @topologies.include?(@asset)
      end
      should "contain the topology" do
        assert @topologies.include?(@topology)
      end
    end
  end 
  
  context "destroying an asset" do
    setup do
      @type = Factory.create(:object_type)
      @unit_type = Factory.create(:eng_unit_type)
      @object_datum1 = Factory.create(:object_datum, :attribute_type => @type, :eng_unit_type => @unit_type)
      @object_datum2 = Factory.create(:object_datum, :attribute_type => @type, :eng_unit_type => @unit_type)
      @object_datum3 = Factory.create(:object_datum, :attribute_type => @type, :eng_unit_type => @unit_type)
      @object_datum4 = Factory.create(:object_datum, :attribute_type => @type, :eng_unit_type => @unit_type)
      @mloc1 = Factory.create(:meas_location, :default_eng_unit_type => @unit_type, :object_data => [@object_datum1, @object_datum2])
      @mloc2 = Factory.create(:meas_location, :default_eng_unit_type => @unit_type, :object_data => [@object_datum3, @object_datum4])
      @source = Factory.create(:segment, :object_type => @type, :meas_locations => [@mloc1, @mloc2])
      @target = Factory.create(:segment, :object_type => @type)
      @edge = Factory.create(:network_connection, :source => @source, :target => @target)      
      @network = Factory.create(:network, :object_type => @type, :entry_edges =>[@edge])
      @vnet = Factory.create(:valid_network, :network => @network)
      @asset = Factory.create(:asset, :valid_network => @vnet)
      @asset.destroy
    end
    should "delete the asset" do
      assert !Asset.find_by_guid(@asset.guid)
    end
    should "delete the valid network" do
      assert !ValidNetwork.find_by_guid(@vnet.guid)
    end
    should "delete the network" do
      assert !Network.find_by_guid(@network.guid)
    end
    should "delete the network Connection" do
      assert !NetworkConnection.find_by_guid(@edge.guid)
    end
    should "delete the source and target" do
      assert !Segment.find_by_guid(@target.guid)
      assert !Segment.find_by_guid(@source.guid)
    end
    should "delete the mesaurment locations" do
      assert !MeasLocation.find_by_guid(@mloc1.guid)
      assert !MeasLocation.find_by_guid(@mloc2.guid)
    end
    should "delete the object datum" do
      assert !ObjectDatum.find_by_guid(@object_datum1.guid)
      assert !ObjectDatum.find_by_guid(@object_datum2.guid)
    end
    should "NOT delete the Engineering Unit Type" do
      assert EngUnitType.find_by_guid(@unit_type.guid)            
    end    
    should "NOT delete the type" do
      assert ObjectType.find_by_guid(@type.guid)
    end
  end
  
  context "duplicating an asset" do
    setup do
      @model = Factory.create(:model)
      @manufacturer = Factory.create(:manufacturer)
      @asset1 = Factory.create(:asset, :model => @model, :manufacturer => @manufacturer)
      @asset2 = @asset1.dup_entity
    end
    should "create two separate asset objects" do
      assert_not_equal @asset1, @asset2
      assert_equal @asset1.guid, @asset2.guid
    end
    should "create two objects with identical information" do
      assert_not_equal @asset1, @asset2
      @asset1.field_names do |field|
        assert_equal @asset1.send("#{field}"), @asset2.send("#{field}")
      end
    end
    should "copy over the asset manufacturer" do
      assert_not_equal @asset1.manufacturer, @asset2.manufacturer
      @asset1.manufacturer.field_names do |field|
        assert_equal @asset1.manufacturer.send("#{field}"), @asset2.manufacturer.send("#{field}")
      end
    end
    should "copy over the asset model" do
      assert_not_equal @asset1.model, @asset2.model
      @asset1.model.field_names do |field|
        assert_equal @asset1.model.send("#{field}"), @asset2.model.send("#{field}")
      end
    end
    context "with new guids" do
      setup do
        @asset2 = @asset1.dup_entity(:gen_new_guids => true)
      end
      should "create two separate asset objects" do
        assert_not_equal @asset1, @asset2
      end
      should "gen new guids for the assets" do
        assert_not_equal @asset1.guid, @asset2.guid
      end
      should "keep guids same for model" do
        assert_equal @asset1.model.guid, @asset2.model.guid
      end
      should "keep guids same for manufacturer" do
        assert_equal @asset1.manufacturer.guid, @asset2.manufacturer.guid
      end
    end
  end
end
