class ToEntityController < CcomRestController
  def index
    super(ToEntity.find(:all))
  end

end
