require 'net/http'

class AssetObserver
  def self.install(asset, hist)
    if e = ActualEvent.create(:monitored_object => asset, :hist => hist, :object_type => ObjectType.install_event)
      publish(e)
    end
  end

  def self.remove(asset, hist)
    if e = ActualEvent.create(:monitored_object => asset, :hist => hist, :object_type => ObjectType.remove_event)
      publish(e)
    end
  end

  def self.publish(event)
    Net::HTTP.start(POSTBACK_HOST, POSTBACK_PORT) do |http|
      http.post(POSTBACK_PATH, event.to_xml)
    end
  end
end
