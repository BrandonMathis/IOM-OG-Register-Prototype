class ActualEventController < CcomRestController
  def index
    super ActualEvent.find(:all)
  end
end
