# encoding: utf-8
module Mongoid #:nodoc:
  module Matchers #:nodoc:
    class Lte < Default
      # Return true if the attribute is less than or equal to the value.
      def matches?(value)
        @attribute ? @attribute <= first(value) : false
      end
    end
  end
end
