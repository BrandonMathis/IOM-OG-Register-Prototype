require 'test_helper'

class CcomDataTest < ActiveSupport::TestCase

  context "with a topology xml file" do
    setup do
      xml = File.read(File.join(Rails.root, "db", "xml", "topology.xml"))
      @entity = CcomData.from_xml(xml)
    end

    should "be an entierprise" do
      assert_kind_of Enterprise, @entity
    end
  end
end
