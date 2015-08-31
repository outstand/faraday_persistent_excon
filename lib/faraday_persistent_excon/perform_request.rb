module FaradayPersistentExcon
  class PerformRequest
    attr_accessor :env

    def call(env)
      @env = env

      resp = nil
      ConnectionPools.with_connection_for(url_without_path.to_s) do |conn|
        resp = conn.request(request_options)
      end

    rescue ::Excon::Errors::SocketError => err
      if err.message =~ /\btimeout\b/
        raise Faraday::Error::TimeoutError, err
      elsif err.message =~ /\bcertificate\b/
        raise Faraday::Error::SSLError, err
      else
        raise Faraday::Error::ConnectionFailed, err
      end
    rescue ::Excon::Errors::Timeout => err
      raise Faraday::Error::TimeoutError, err
    end

    protected

    def request_options
      RequestOptions.new(env).call.merge(
        method: env[:method].to_s.upcase,
        path: env[:url].path,
        query: env[:url].query,
        headers: env[:request_headers],
        body: read_body
      )
    end

    # TODO: support streaming requests
    def read_body
      env[:body].respond_to?(:read) ? env[:body].read : env[:body]
    end

    def url_without_path
      env[:url].dup.tap do |url|
        url.path = ''
        url.query = nil
        url.fragment = nil
      end
    end
  end
end
