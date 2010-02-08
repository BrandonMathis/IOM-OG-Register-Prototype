require 'rubygems'
require 'sinatra'

EVENTS_PATH = File.expand_path(File.dirname(__FILE__) + "/../public/events")

get '/hello' do
    'Hello World'
end

post '/events' do
  File.open(File.join(EVENTS_PATH, "#{Time.now.strftime('%Y%m%dT%H%M%S')}.xml"), "w") do |f|
    f.write request.body
  end
  request.body
end
