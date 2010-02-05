class NetworkConnection < CcomObject
  has_one :source
  field :ordering_seq, :type => Integer
end
