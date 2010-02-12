require 'asset'
require 'net/http'

class AssetObserver
  def self.install(asset,segment)
    if e = Event.create(:monitored_object => asset, :for => segment, :object_type => ObjectType.install_event)
      publish(e)
    end
  end

  def self.remove(asset, segment)
    if e = Event.create(:monitored_object => asset, :for => segment, :object_type => ObjectType.remove_event)
      publish(e)
    end
  end

  def self.publish(event)
    Net::HTTP.start(POSTBACK_HOST, POSTBACK_PORT) do |http|
      http.post(POSTBACK_PATH, event.to_xml)
    end
  end
end

class Asset
  def installed_on_segment_with_observer=(segment_to_assign)
    if self.installed_on_segment
      # if it has an installed on segment, generate a remove event
      AssetObserver.remove(self, self.installed_on_segment)
    end
    unless segment_to_assign.nil?
      # if a new segment is passed in, generate an install event
      AssetObserver.install(self, segment_to_assign)
    end
    self.installed_on_segment_without_observer=(segment_to_assign)
  end

  alias_method_chain :installed_on_segment=, :observer
end
