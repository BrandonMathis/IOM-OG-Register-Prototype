require 'lib/postback_server'
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

    should_change ("number of event files", :by => 1) { Dir.entries(EVENTS_PATH).size }

    should "write the proper data to the file" do
      new_entry = (Dir.entries(EVENTS_PATH) - @start_entries).first
      assert_equal @data, File.read(File.join(EVENTS_PATH,new_entry))
    end
  end

  context "posting a real ccom event" do
    setup do
      @user_tag = "Model Z400-A1 S/N 3Z84G32AA0-4 AC Induction Motor"
      @event_xml = "<?xml version='1.0' encoding='UTF-8'?> <CCOMData xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns='http://www.mimosa.org/osa-eai/v3-3/xml/CCOM-ML'> <Event> <guid>251ff520-e40e-11de-8a39-0800200c9a36</guid> <userTag>#{@user_tag}</userTag></Event></CCOMData>"
      post '/events', @event_xml
      @new_filename = (Dir.entries(EVENTS_PATH) - @start_entries).first
    end

    should "create a file with the event's user tag as the name" do
      assert_match @user_tag.tr("/\000", ""), @new_filename
      assert_match /.xml$/, @new_filename
    end
  end

  def teardown
    Dir.entries(EVENTS_PATH).each do |e|
      next if @start_entries.include?(e)
      File.delete(File.join(EVENTS_PATH, e))
    end
  end
end
