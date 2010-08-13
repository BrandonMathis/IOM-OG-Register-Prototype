def Mongoid.drop_all_collections
  self.database.collections.each do |collection|
    collection.drop
  end
end
