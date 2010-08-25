require 'rubygems'
require 'sinatra'
require 'nokogiri'

EVENTS_PATH = File.expand_path(File.dirname(__FILE__) + "/../events")

get '/hello' do
    'Hello World'
end

post '/CCOMData/Event' do
  data = request.body.read
  time = Time.now.strftime('%Y%m%dT%H%M%S')
  if (doc = Nokogiri::XML.parse(data) rescue nil)
    unless (tag = doc.xpath("//ccom:Tag", "ccom" => "http://www.mimosa.org/osa-eai/v3-3/xml/CCOM-ML").first).nil?
      # FIXME: don't have good tests for this filename escaping
      # http://www.ruby-forum.com/topic/124471
      filename = time + " " + File.basename(tag.content.tr("/\000", "")) + ".xml"
    end
  end
  filename ||= "No CCOMData userTag: #{time}.xml"
  File.open(File.join(EVENTS_PATH, filename), "w") do |f|
    f.write data
  end
end
