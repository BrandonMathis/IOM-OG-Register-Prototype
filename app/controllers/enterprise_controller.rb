class EnterpriseController < CcomRestController
  def index
    super(Enterprise.find(:all))
  end
end
