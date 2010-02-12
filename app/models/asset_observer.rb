#require 'asset'

class AssetObserver
  def self.install(asset,segment)
    Event.create(:monitored_object => asset, :for => segment, :object_type => ObjectType.install_event)
  end

  def self.remove(asset, segment)
    Event.create(:monitored_object => asset, :for => segment, :object_type => ObjectType.remove_event)
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
