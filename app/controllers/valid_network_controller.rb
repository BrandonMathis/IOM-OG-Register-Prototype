class ValidNetworkController < CcomRestController
  def index
    super(ValidNetwork.find(:all))
  end
  
end
