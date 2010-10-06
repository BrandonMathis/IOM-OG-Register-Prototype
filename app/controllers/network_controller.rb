class NetworkController < CcomRestController
  def index
    super(Network.find(:all))
  end
end
