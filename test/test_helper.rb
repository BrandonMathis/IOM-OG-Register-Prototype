ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  # self.use_instantiated_fixtures  = false
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def assert_not_valid(object, msg="Object is valid when it should be invalid")
    assert(!object.valid?, msg)
  end
  alias :assert_invalid :assert_not_valid
  
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
  teardown :flexmock_teardown

  def setup
    stub_request(:post, POSTBACK_URI)
  end

  def purge_mongoid
    # purge the CCOM test Database
    Mongoid.database = Mongo::Connection.new(MONGO_HOST, nil, :slave_ok => true).db(CCOM_DATABASE)
    Mongoid.drop_all_collections
    # then the Sandbox test Database
    Mongoid.database = Mongo::Connection.new(MONGO_HOST, nil, :slave_ok => true).db(ROOT_DATABASE)
    Mongoid.drop_all_collections
  end

end


Webrat.configure {|config| config.mode = :rails; config.open_error_files = false }

module ActiveSupport
  class BacktraceCleaner
    def remove_filters!
      @filters = []
    end
  end
end


Rails.backtrace_cleaner.remove_silencers!
Rails.backtrace_cleaner.remove_filters!
