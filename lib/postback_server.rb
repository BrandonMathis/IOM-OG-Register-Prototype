require 'rubygems'
require 'sinatra'
require 'nokogiri'

EVENTS_PATH = File.expand_path(File.dirname(__FILE__) + "/../events")

get '/hello' do
    'Hello World'
end

post '/events' do
  data = request.body.read
  if (doc = Nokogiri::XML.parse(data) rescue nil)
    unless (user_tag = doc.xpath("//ccom:userTag", "ccom" => "http://www.mimosa.org/osa-eai/v3-3/xml/CCOM-ML").first).nil?
      # FIXME: don't have good tests for this filename escaping
      # http://www.ruby-forum.com/topic/124471
      filename = File.basename(user_tag.content.tr("/\000", "")) + ".xml"
    end
  end
  filename ||= "No CCOMData userTag: #{Time.now.strftime('%Y%m%dT%H%M%S')}.xml"
  File.open(File.join(EVENTS_PATH, filename), "w") do |f|
    f.write data
  end
end
