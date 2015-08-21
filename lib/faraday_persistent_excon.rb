require 'faraday'
require 'thread_safe'
require 'connection_pool'
require 'active_support'
require 'active_support/core_ext/class/attribute'

require "faraday_persistent_excon/version"

Faraday::Adapter.register_middleware persistent_excon: ->{ FaradayPersistentExcon::Adapter }

module FaradayPersistentExcon
  class Adapter < Faraday::Adapter
    dependency 'excon'
    class_attribute :excon_options
    class_attribute :connection_pools
    class_attribute :__pools
    self.__pools = ThreadSafe::Cache.new

    def self.with_connection_for(url, &block)
      pool = self.connection_pool_for(url)

      if pool
        begin
          pool.with(&block)
        rescue ::Excon::Errors::SocketError
          pool.shutdown { |conn| conn.reset }
          self.__pools.delete(url)
          raise
        end
      else
        block.call(::Excon.new(url, persistent: false))
      end
    end

    def self.connection_pool_for(url)
      config = self.connection_pools.find do |hsh|
        hsh[:url] == url
      end

      if config
        self.__pools.fetch_or_store(url) do
          ConnectionPool.new(size: config[:size]) do
            ::Excon.new(config[:url], persistent: true, thread_safe_sockets: false)
          end
        end
      end
    end

    def call(env)
      super

      opts = self.excon_options.nil? ? {} : self.excon_options
      if env[:url].scheme == 'https' && ssl = env[:ssl]
        opts[:ssl_verify_peer] = !!ssl.fetch(:verify, true)
        opts[:ssl_ca_path] = ssl[:ca_path] if ssl[:ca_path]
        opts[:ssl_ca_file] = ssl[:ca_file] if ssl[:ca_file]
        opts[:client_cert] = ssl[:client_cert] if ssl[:client_cert]
        opts[:client_key]  = ssl[:client_key]  if ssl[:client_key]
        opts[:certificate] = ssl[:certificate] if ssl[:certificate]
        opts[:private_key] = ssl[:private_key] if ssl[:private_key]
      end

      if ( req = env[:request] )
        if req[:timeout]
          opts[:read_timeout]      = req[:timeout]
          opts[:connect_timeout]   = req[:timeout]
          opts[:write_timeout]     = req[:timeout]
        end

        if req[:open_timeout]
          opts[:connect_timeout]   = req[:open_timeout]
          opts[:write_timeout]     = req[:open_timeout]
        end

        if req[:proxy]
          opts[:proxy] = {
            host: req[:proxy][:uri].host,
            port: req[:proxy][:uri].port,
            scheme: req[:proxy][:uri].scheme,
            user: req[:proxy][:user],
            password: req[:proxy][:password]
          }
        end
      end

      url_no_path = env[:url].dup
      url_no_path.path = ''
      url_no_path.query = nil
      url_no_path.fragment = nil

      resp = nil
      self.class.with_connection_for(url_no_path.to_s) do |conn|
        resp = conn.request \
          method: env[:method].to_s.upcase,
          path: env[:url].path,
          query: env[:url].query,
          headers: env[:request_headers],
          body: read_body(env)
      end

      save_response(env, resp.status.to_i, resp.body, resp.headers)

      @app.call env
    rescue ::Excon::Errors::SocketError => err
      if err.message =~ /\btimeout\b/
        raise Error::TimeoutError, err
      elsif err.message =~ /\bcertificate\b/
        raise Faraday::SSLError, err
      else
        raise Error::ConnectionFailed, err
      end
    rescue ::Excon::Errors::Timeout => err
      raise Error::TimeoutError, err
    end

    # TODO: support streaming requests
    def read_body(env)
      env[:body].respond_to?(:read) ? env[:body].read : env[:body]
    end
  end
end
