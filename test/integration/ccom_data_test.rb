require 'test_helper'

class CcomDataTest < ActiveSupport::TestCase

  context "with a topology xml file" do
    setup do
      xml = File.read(File.join(Rails.root, "db", "xml", "topology.xml"))
      @enterprise = CcomData.from_xml(xml).first
    end

    should "be an enterprise" do
      assert_kind_of Enterprise, @enterprise
    end

    context "enterprise" do
      should "have a controlled site" do
        assert @enterprise.controlled_site
      end
    end

    context "controlled site" do
      setup do
        @site = @enterprise.controlled_site
      end
      should "have an equivalent segment" do
        assert_kind_of Segment, @site.equivalent_segment
      end
      should "have an object type" do
        assert_kind_of Type, @site.type
      end
      context "equivalent segment" do
        setup do
          @segment = @site.equivalent_segment
        end
        should "have an installed asset" do
          assert_kind_of Asset, @segment.installed_assets.first
        end
        should_eventually "have a topology asset"
        context "installed asset" do
          setup do
            @asset = @segment.installed_assets.first
          end
          should "have an acn" do
            assert_kind_of AssetConfigNetwork, @asset.valid_network
          end
          should "have an associated network" do
            assert_kind_of Network, @asset.network
            assert_equal "7f38782d-e026-4259-b8f9-5425920e457b", @asset.network.g_u_i_d
          end
          should "have an entry point" do
            assert_kind_of NetworkConnection, @asset.entry_edges.first
          end
          context "entry point" do
            setup do
              @entry_edge = @asset.entry_edges.first
            end
            should "have a source segment" do
              assert_kind_of Segment, @entry_edge.source
            end
            should "have a target" do
              assert_kind_of NetworkConnection, @entry_edge.targets.first
            end
          end
        end

      end
    end

    context "segment with a datasheet" do
      setup do
        @segment = Segment.find_by_guid("abcf6703-4d26-4f0b-8f0e-c4d704da514a")
      end
      should "have a segment config network" do
        assert_kind_of SegmentConfigNetwork, @segment.segment_config_network
      end

      context "associated network" do
        setup do
          @network = @segment.segment_config_network.network
        end
        should "be a network" do
          assert_kind_of Network, @network
        end
      end
    end

    context "measurement location" do
      setup do
        @meas_location = MeasLocation.find_by_guid("7dcc3260-912f-456e-b370-749489ec43dd")
      end
      should "be a meas location" do
        assert_kind_of MeasLocation, @meas_location
      end

      context "with object data" do
        setup do
          @object_data = @meas_location.object_data.first
        end
        
        should "be object data" do
          assert_kind_of ObjectDatum, @object_data
        end

        should "have data" do
          assert_equal "2300", @object_data.data
        end

        should "have an eng unit type" do
          assert_kind_of EngUnitType, @object_data.eng_unit_type
        end

        context "with an attribute type" do
          setup do
            @attr_type = @object_data.attribute_type
          end
          should "be an attribute type" do
            assert_kind_of AttributeType, @attr_type
          end
        end
      end
    end
  end
end
