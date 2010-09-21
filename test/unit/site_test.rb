require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:site)
  end

  should "support an equivalent segment" do
    segment = Factory.create(:segment)
    assert_valid site = Factory.create(:site, :equivalent_segment => segment)
    assert_equal segment, site.equivalent_segment
  end
end
