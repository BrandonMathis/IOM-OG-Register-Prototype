if defined?(HTTPClient)

  class HTTPClient

    def do_get_block_with_webmock(req, proxy, conn, &block)
      do_get_with_webmock(req, proxy, conn, false, &block)
    end

    def do_get_stream_with_webmock(req, proxy, conn, &block)
      do_get_with_webmock(req, proxy, conn, true, &block)
    end

    def do_get_with_webmock(req, proxy, conn, stream = false, &block)
      request_signature = build_request_signature(req)

      WebMock::RequestRegistry.instance.requested_signatures.put(request_signature)

      if WebMock.registered_request?(request_signature)
        webmock_response = WebMock.response_for_request(request_signature)
        response = build_httpclient_response(webmock_response, stream, &block)
        conn.push(response)
      elsif WebMock.net_connect_allowed?
        if stream
          do_get_stream_without_webmock(req, proxy, conn, &block)
        else
          do_get_block_without_webmock(req, proxy, conn, &block)
        end
      else
        message = "Real HTTP connections are disabled. Unregistered request: #{request_signature}"
        WebMock.assertion_failure(message)
      end
    end

    def do_request_async_with_webmock(method, uri, query, body, extheader)
      req = create_request(method, uri, query, body, extheader)
      request_signature = build_request_signature(req)
      
      if WebMock.registered_request?(request_signature) || WebMock.net_connect_allowed?
        do_request_async_without_webmock(method, uri, query, body, extheader)
      else
        message = "Real HTTP connections are disabled. Unregistered request: #{request_signature}"
        WebMock.assertion_failure(message)
      end
    end

    alias_method :do_get_block_without_webmock, :do_get_block
    alias_method :do_get_block, :do_get_block_with_webmock

    alias_method :do_get_stream_without_webmock, :do_get_stream
    alias_method :do_get_stream, :do_get_stream_with_webmock

    alias_method :do_request_async_without_webmock, :do_request_async
    alias_method :do_request_async, :do_request_async_with_webmock

    def build_httpclient_response(webmock_response, stream = false, &block)
      body = stream ? StringIO.new(webmock_response.body) : webmock_response.body
      response = HTTP::Message.new_response(body)
      response.header.init_response(webmock_response.status)

      webmock_response.headers.to_a.each { |name, value| response.header.set(name, value) }

      webmock_response.raise_error_if_any

      block.call(nil, body) if block

      response
    end
  end

  def build_request_signature(req)
    uri = Addressable::URI.heuristic_parse(req.header.request_uri.to_s)
    uri.query_values = req.header.request_query if req.header.request_query
    uri.port = req.header.request_uri.port
    uri = uri.omit(:userinfo)

    auth = www_auth.basic_auth
    auth.challenge(req.header.request_uri, nil)

    headers = Hash[*req.header.all.flatten]

    if (auth_cred = auth.get(req)) && auth.scheme == 'Basic'
      userinfo = WebMock::Util::Headers.decode_userinfo_from_header(auth_cred)
      userinfo = WebMock::Util::URI.encode_unsafe_chars_in_userinfo(userinfo)
      headers.reject! {|k,v| k =~ /[Aa]uthorization/ && v =~ /^Basic / } #we added it to url userinfo
      uri.userinfo = userinfo
    end

    request_signature = WebMock::RequestSignature.new(
      req.header.request_method.downcase.to_sym,
      uri.to_s,
      :body => req.body.content,
      :headers => headers
    )
  end

end
