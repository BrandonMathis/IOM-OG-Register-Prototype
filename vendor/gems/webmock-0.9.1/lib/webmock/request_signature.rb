module WebMock

  class RequestSignature < Request

    def match(request_profile)
      raise ArgumentError unless request_profile.is_a?(RequestProfile)
      match_method(request_profile) &&
        match_body(request_profile) &&
        match_headers(request_profile) &&
        match_uri(request_profile) &&
        match_with_block(request_profile)
    end

    private

    def match_uri(request_profile)
      if request_profile.uri.is_a?(Addressable::URI)
        WebMock::Util::URI.normalize_uri(uri) === WebMock::Util::URI.normalize_uri(request_profile.uri)
      elsif request_profile.uri.is_a?(Regexp)
        WebMock::Util::URI.variations_of_uri_as_strings(self.uri).any? { |u| u.match(request_profile.uri) }
      else
        false
      end
    end

    def match_headers(request_profile)
      return false if self.headers && !self.headers.empty? && request_profile.headers && request_profile.headers.empty?
      if request_profile.headers && !request_profile.headers.empty?
        request_profile.headers.each do | key, value |
          return false unless (self.headers && self.headers.has_key?(key) && value === self.headers[key])
        end
      end
      return true
    end

    def match_body(request_profile)
      request_profile.body == self.body || request_profile.body.nil?
    end

    def match_method(request_profile)
      request_profile.method == self.method || request_profile.method == :any
    end
    
    def match_with_block(request_profile)
      return true unless request_profile.with_block
      request_profile.with_block.call(self)
    end
  end


end
