class NetworkConnectionController < CcomRestController
  def index
    super(NetworkConnection.find(:all))
  end
end