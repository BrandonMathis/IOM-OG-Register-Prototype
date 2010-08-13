# encoding: utf-8
module Mongoid #:nodoc
  module Commands #:nodoc
    module Deletion #:nodoc
      # If the +Document+ has a parent, delete it from the parent's attributes,
      # otherwise delete it from it's collection.
      def delete(doc)
        parent = doc._parent
        if parent
          parent.remove(doc)
          parent.save
        else
          doc.collection.remove(:_id => doc.id)
        end
      end
    end
  end
end
