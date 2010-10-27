def Mongoid.drop_all_collections
  entities = CcomEntity.find(:all)
  entities.each {|entity| entity.delete}
  #self.database.collections.each do |collection|
  #  collection.drop
  #end
end
