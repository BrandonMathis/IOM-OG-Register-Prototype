def Mongoid.drop_all_collections
  self.database.collections.each { |collection| collection.drop }
end
