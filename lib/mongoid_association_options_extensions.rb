module Mongoid #:nodoc:
  module Associations #:nodoc:
    class Options #:nodoc:

      def xml_prefix
        @attributes[:xml_prefix] || "has"
      end

      def xml_element
        element_name = name.singularize.camelize
        if xml_prefix != :blank
          element_name = "#{xml_prefix}#{element_name}"
        end
        @attributes[:xml_element] || element_name.camelize(:lower)
      end     
    end
  end
end
