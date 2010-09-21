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
end
