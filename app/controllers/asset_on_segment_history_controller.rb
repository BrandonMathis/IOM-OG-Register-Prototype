class AssetOnSegmentHistoryController < CcomRestController
  def index
    super AssetOnSegmentHistory.find(:all)
  end
end
