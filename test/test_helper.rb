ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  # self.use_instantiated_fixtures  = false
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def mimosa_xmlns
    { "mimosa" => MIMOSA_XMLNS }
  end

  def assert_has_xpath(path, doc, opts = {})
    opts = { :mimosa => true }.merge(opts)
    search_path = opts[:mimosa] ? path.to_mimosa : path
    xmlns = mimosa_xmlns if opts[:mimosa]
    found_doc =  doc.xpath(search_path, xmlns)
    assert_not_nil found_doc.first, "Could not find #{path} in\n#{doc.to_s}"
  end

  include WebMock

  teardown :purge_mongoid

  def setup
    stub_request(:post, POSTBACK_URI)
  end

  def purge_mongoid
    Mongoid.database.collections.each do |collection|
      collection.drop
    end
  end
end


Webrat.configure {|config| config.mode = :rails; config.open_error_files = false }

class String
  def to_mimosa
    self.gsub(/(\/+)/, '\1mimosa:')
  end
end

class Nokogiri::XML::Node
  def mimosa_xpath(path)
    xpath(path.to_mimosa, { "mimosa" => MIMOSA_XMLNS } )
  end
end
