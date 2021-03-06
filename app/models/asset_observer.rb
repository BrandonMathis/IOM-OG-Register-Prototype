require 'net/http'

class AssetObserver
  
  # Will fire off a Mimosa CCOM Install Event XML via HTTP POST
  # using the data of the asset and generated AssetOnSegmentHistory
  #
  # The Event is created and logged in the Active Registry
  def self.install(asset, hist)
    if e = ActualEvent.create(:monitored_object => asset, :hist => hist, :object_type => ObjectType.install_event)
      publish(e)
    end
  end
  # Will fire off a Mimosa CCOM Removed Event XML via HTTP POST
  # using the data of the asset and generated AssetOnSegmentHistory
  # 
  # The Event is created and logged in the Active Registry 
  def self.remove(asset, hist)
    if e = ActualEvent.create(:monitored_object => asset, :hist => hist, :object_type => ObjectType.remove_event)
      publish(e)
    end
  end

  protected
  def self.publish(event)
    Net::HTTP.start(POSTBACK_HOST, POSTBACK_PORT) do |http|
      http.post(POSTBACK_PATH, event.to_xml)
    end
    if $isbm_host != POSTBACK_HOST
      Net::HTTP.start($isbm_host, $isbm_port) do |http|
        http.post($isbm_path, event.to_xml)
      end
    end
  end
end
