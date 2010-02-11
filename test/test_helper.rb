ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'flexmock/test_unit'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  # self.use_instantiated_fixtures  = false
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def mimosa_xmlns
    { "mimosa" => CcomEntity.xmlns }
  end
end
Webrat.configure {|config| config.mode = :rails; config.open_error_files = false }

class String
  def to_mimosa
    self.gsub('/', '/mimosa:')
  end
end
