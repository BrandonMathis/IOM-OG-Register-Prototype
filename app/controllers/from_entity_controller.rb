class FromEntityController < CcomRestController
  def index
    super(FromEntity.find(:all))
  end
end
