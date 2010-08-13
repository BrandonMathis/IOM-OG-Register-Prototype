require 'asset'
require 'net/http'

class AssetObserver
  def self.install(asset,segment)
    if e = Event.create(:monitored_object => asset, :for => segment, :type => Type.install_event)
      publish(e)
    end
  end

  def self.remove(asset, segment)
    if e = Event.create(:monitored_object => asset, :for => segment, :type => Type.remove_event)
      publish(e)
    end
  end

  def self.publish(event)
    Net::HTTP.start(POSTBACK_HOST, POSTBACK_PORT) do |http|
      #http.post(POSTBACK_PATH, event.to_xml)
    end
  end
end
