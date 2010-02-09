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

    should_change "Dir.entries(EVENTS_PATH).size", :by => 1

    should "write the proper data to the file" do
      new_entry = (Dir.entries(EVENTS_PATH) - @start_entries).first
      assert_equal @data, File.read(File.join(EVENTS_PATH,new_entry))
    end
  end

  def teardown
    Dir.entries(EVENTS_PATH).each do |e|
      next if @start_entries.include?(e)
      File.delete(File.join(EVENTS_PATH, e))
    end
  end
end
