require 'test_helper'

class EnterpriseTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:enterprise)
  end

  should "support a controlled site" do
    site = Factory.create(:site)
    assert_valid enterprise = Factory.create(:enterprise, :controlled_site => site)
    assert_equal site, enterprise.controlled_site
  end
end
