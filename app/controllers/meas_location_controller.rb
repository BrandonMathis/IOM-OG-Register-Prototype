class MeasLocationController < CcomRestController
  def index
    super(MeasLocation.find(:all))
  end
end
