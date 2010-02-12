module WebMock
  class RequestStub

    attr_accessor :request_profile, :responses

    def initialize(method, uri)
      @request_profile = RequestProfile.new(method, uri)
      @responses_sequences = []
      self
    end

    def with(params = {}, &block)
      @request_profile.with(params, &block)
      self
    end

    def to_return(*response_hashes)
      @responses_sequences << ResponsesSequence.new([*response_hashes].flatten.map {|r| WebMock::Response.new(r)})
      self
    end

    def to_raise(*exceptions)
      @responses_sequences << ResponsesSequence.new([*exceptions].flatten.map {|e| WebMock::Response.new(:exception => e)})
      self
    end

    def response
      if @responses_sequences.empty?
        WebMock::Response.new
      elsif @responses_sequences.length > 1
        @responses_sequences.shift if @responses_sequences.first.end?
        @responses_sequences.first.next_response
      else
        @responses_sequences[0].next_response
      end
    end

    def then
      self
    end

    def times(number)
      raise "times(N) accepts integers >= 1 only" if !number.is_a?(Fixnum) || number < 1
      if @responses_sequences.empty?
        raise "Invalid WebMock stub declaration." +
          " times(N) can be declared only after response declaration."
      end
      @responses_sequences.last.times_to_repeat += number-1
      self
    end

  end
end
