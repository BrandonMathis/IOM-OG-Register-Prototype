class FromEntityController < SegmentsController
  def index
    super(FromEntity.find(:all))
  end
end
