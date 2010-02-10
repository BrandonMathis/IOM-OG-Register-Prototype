#require 'asset'

class AssetObserver
  def self.install(asset,segment)
  end

  def self.remove(asset, segment)
  end
end

class Asset
  def installed_on_segment_with_observer=(segment)
    if self.installed_on_segment
      AssetObserver.remove(self, self.installed_on_segment)
    end
    unless segment.nil?
      AssetObserver.install(self, segment)
    end
    self.installed_on_segment_without_observer=(segment)
  end

  alias_method_chain :installed_on_segment=, :observer
end
