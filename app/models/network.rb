class Network < CcomObjectWithChildren
  has_many :entry_points, :class_name => "NetworkConnection"
end
