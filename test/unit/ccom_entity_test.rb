require 'test_helper'

class CcomEntityTest < ActiveSupport::TestCase

  should "be valid from factory" do
    assert_valid Factory.create(:ccom_entity)
  end

  should "allow setting utc last updated" do
    assert_valid Factory.create(:ccom_entity, :utc_last_updated => Time.now.utc)
  end

  context "a new ccom entity with a blank guid" do
    setup { @ccom_entity = Factory.build(:ccom_entity, :guid => nil) }
    
    should "have a blank guid" do
      assert @ccom_entity.guid.blank?, "'#{@ccom_entity.guid}' isn't blank"
    end
    
    context "after saving" do
      setup do
        @uuid = "a;lskjdfq;lkwjer;wj;laksjdf;lkqjwe"
        flexmock(UUID).should_receive(:generate).returns(@uuid).once
        @ccom_entity.save
      end

      should "have the generated guid" do
        assert_equal @uuid, @ccom_entity.guid
      end
    end
  end

  should "find by guid" do
    entity = Factory.create(:ccom_entity)
    assert_not_nil found = CcomEntity.find_by_guid(entity.guid)
    assert_equal found, entity
  end

  context "to xml" do
    setup do
      @ccom_entity = Factory.create(:ccom_entity, 
                                    :id_in_source => "0000000000000000.1.125",
                                    :source_id => "www.mimosa.org/CRIS/V3-2-1/meas_loc_type",
                                    :user_name => "Vibration, Absolute, Casing, Broadband")
      @xml = @ccom_entity.to_xml
      @doc = Nokogiri::XML.parse(@xml)
    end

    should "generate the proper root node" do
      assert_equal "CCOMData", @doc.root.name
    end

    should "include id in source" do
      xpath = "/CCOMData/CCOMEntity/idInSource"
      node_set = @doc.xpath(xpath.to_mimosa, mimosa_xmlns)
      assert_not_nil node_set.first, "#{xpath}\n#{@xml.inspect}\n#{@doc.inspect}"
#      assert_equal @ccom_entity.id_in_source, 
    end

    should "not include status code when it's blank" do
      node_set = @doc.xpath("//CCOMEntity/statusCode", mimosa_xmlns)
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
      @entity = Factory.create(:ccom_entity, :user_tag => "foobar")
      @guid = @entity.guid = UUID.generate
      @xml = @entity.to_xml
      @parsed_entity = CcomEntity.from_xml(@xml)
    end

    should "have the right details" do
      [:guid, :user_tag].each do |attr|
        assert_equal @entity.send(attr), @parsed_entity.send(attr)
      end
    end
  end
end
