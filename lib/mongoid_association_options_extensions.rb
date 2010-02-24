module Mongoid #:nodoc:
  module Associations #:nodoc:
    class Options #:nodoc:
      def xml_element
        @attributes[:xml_element] || name.singularize.camelize(:lower)
      end     
    end
  end
end
