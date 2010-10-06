class EngUnitTypeController < CcomRestController
  def index
    super(EngUnitType.find(:all))
  end
end
