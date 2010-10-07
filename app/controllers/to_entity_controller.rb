class ToEntityController < SegmentsController
  def index
    super(ToEntity.find(:all))
  end

end
