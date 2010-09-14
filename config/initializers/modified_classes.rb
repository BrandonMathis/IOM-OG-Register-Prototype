class String
  def display_name
    return "Native System ID" if self.eql? "IDInInfoSource"
    return "Last Edited" if self.eql? "LastEdited"
    return self
  end
end