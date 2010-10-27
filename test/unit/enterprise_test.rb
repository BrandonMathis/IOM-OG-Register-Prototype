require 'test_helper'

class EnterpriseTest < ActiveSupport::TestCase

  def setup
    @site = Factory.create(:site)
    assert_valid @enterprise = Factory.create(:enterprise, :controlled_site => @site)
  end
  should "be valid from factory" do
    assert_valid Factory.create(:enterprise)
  end

  should "support a controlled site" do

    assert_equal @site, @enterprise.controlled_site
  end

  context "importing xml" do
    setup do
      @enterprise.g_u_i_d = UUID.generate
      @parsed_enterprise = Enterprise.from_xml(@enterprise.to_xml)
    end

    should "have the site" do
      assert_equal @site, @parsed_enterprise.controlled_site, @enterprise.to_xml
    end
  end
  
  context "duplicating the entity" do
    setup do
      @site = Factory.create(:site)
      @ent1 = Factory.create(:enterprise, :controlled_site => @site)
      @ent2 = @ent1.dup_entity
    end
    should "create two separate objects" do
      assert_not_equal @ent1, @ent2
      assert_equal @ent1.guid, @ent2.guid
    end
    should "copy all attributes" do
      @ent1.field_names.each do |field|
        if @ent1.editable_attribute_names.include?(field)
          assert_equal @ent1.send("#{field}"), @ent2.send("#{field}")
        end
      end
    end
    should "copy all fields for the controlled site" do
      @ent1.controlled_site.field_names.each do |field|
        if @ent1.editable_attribute_names.include?(field)
          assert_equal @ent1.controlled_site.send("#{field}"), @ent2.controlled_site.send("#{field}")
        end
      end
    end
    context "with new guids" do
      setup do
        @ent2 = @ent1.dup_entity(:gen_new_guids => true)
      end
      should "create two objects with different guids" do
        assert_not_equal @ent1, @ent2
        assert_not_equal @ent1.guid, @ent2.guid
      end
      should "create controlled sites with unique guids" do
        assert_not_equal @ent1.controlled_site.guid, @ent2.controlled_site.guid
      end
    end
  end
end
