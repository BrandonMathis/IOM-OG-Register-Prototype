require 'postback_server'
require 'test/unit'
require 'rack/test'
require 'shoulda'

class PostbackServerTest < Test::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @start_entries = Dir.entries(EVENTS_PATH)
  end

  def test_my_default
    get '/hello'
    assert_equal 'Hello World', last_response.body
  end

  context "posting data to events" do
    setup do
      @data = "some block of text"
      post '/events', @data
    end
    
    should "respond with ok" do
      assert last_response.ok?, last_response.inspect
    end

    should "post back the data" do
      assert_equal @data, last_response.body
    end

    should_change "Dir.entries(EVENTS_PATH).size", :by => 1
  end

  def teardown
    Dir.entries(EVENTS_PATH).each do |e|
      next if @start_entries.include?(e)
      File.delete(File.join(EVENTS_PATH, e))
    end
  end
end
