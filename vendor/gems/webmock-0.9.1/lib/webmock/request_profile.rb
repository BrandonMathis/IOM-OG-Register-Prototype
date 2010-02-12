module WebMock

  class RequestProfile < Request
    
    attr_reader :with_block

    def with(options = {}, &block)
      assign_options(options)
      @with_block = block
      self
    end
    
    def body=(body)
      @body = Body.new(body)
    end
    
    def to_s
      string = super
      string << " with given block" if @with_block
      string
    end

    class Body

      attr_reader :data

      def initialize(data)
        @data = data
      end

      def ==(other)
        other = Body.new(other) unless other.is_a?(Body)
        other.is_a?(Body) &&
          (other.is_empty? && self.is_empty? || other.data == self.data || self.data === other.data )        
      end

      def is_empty?
        @data.nil? || @data == ""
      end

      def to_s
        @data
      end

    end

  end


end
