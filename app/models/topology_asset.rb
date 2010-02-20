class TopologyAsset < Asset

  def entry_point=(object)
    self.entry_points.clear
    self.entry_points << object
  end

  def entry_point
    self.entry_points.first
  end

end
