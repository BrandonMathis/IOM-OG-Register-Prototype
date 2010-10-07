class SuccessorController < CcomRestController
  def index
    super(Successor.find(:all))
  end
end
