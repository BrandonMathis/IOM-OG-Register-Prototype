require 'test_helper'

class NetworkTest < ActiveSupport::TestCase
  should "be valid from factory" do
    assert_valid Factory.create(:network)
  end

  should "support an entry point as a network connection" do
    assert_valid Factory.create(:network, :entry_points => [Factory.create(:network_connection)])
  end

  context "generating xml" do
    setup do
      @network = Factory.create(:network, 
                                :entry_points => [Factory.create(:network_connection)])
      builder = Builder::XmlMarkup.new
      xml = builder.Network do |b|
        @network.build_xml(b)
      end
      @doc = Nokogiri::XML.parse(xml)
    end
    
    should "have proper xml name for each entry point" do
      assert_equal 1, @doc.xpath("//Network/hasEntryPoint").size
    end
  end
end
