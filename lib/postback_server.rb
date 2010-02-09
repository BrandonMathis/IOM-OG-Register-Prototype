require 'rubygems'
require 'sinatra'

EVENTS_PATH = File.expand_path(File.dirname(__FILE__) + "/../public/events")

get '/hello' do
    'Hello World'
end

post '/events' do
  filename = "#{Time.now.strftime('%Y%m%dT%H%M%S')}.xml"
  File.open(File.join(EVENTS_PATH, filename), "w") do |f|
    f.write request.body.read
  end
end
