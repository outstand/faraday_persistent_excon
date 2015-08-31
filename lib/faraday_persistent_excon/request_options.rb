module FaradayPersistentExcon
  class RequestOptions
    attr_accessor :env

    def initialize(env)
      @env = env
    end

    def call
      opts = FaradayPersistentExcon.excon_options.dup

      https_options(opts)
      timeout_options(opts)
      proxy_options(opts)

      if FaradayPersistentExcon.retry_idempotent_methods && FaradayPersistentExcon.idempotent_methods.include?(env[:method].to_s.upcase)
        opts[:idempotent] = true
      end

      opts
    end

    protected

    def request
      env[:request]
    end

    def ssl
      env[:ssl]
    end

    def https_options(opts)
      if env[:url].scheme == 'https' && ssl
        opts[:ssl_verify_peer] = !!ssl.fetch(:verify, true)
        opts[:ssl_ca_path] = ssl[:ca_path] if ssl[:ca_path]
        opts[:ssl_ca_file] = ssl[:ca_file] if ssl[:ca_file]
        opts[:client_cert] = ssl[:client_cert] if ssl[:client_cert]
        opts[:client_key]  = ssl[:client_key]  if ssl[:client_key]
        opts[:certificate] = ssl[:certificate] if ssl[:certificate]
        opts[:private_key] = ssl[:private_key] if ssl[:private_key]
      end
    end

    def timeout_options(opts)
      return unless request

      if request[:timeout]
        opts[:read_timeout]      = request[:timeout]
        opts[:connect_timeout]   = request[:timeout]
        opts[:write_timeout]     = request[:timeout]
      end

      if request[:open_timeout]
        opts[:connect_timeout]   = request[:open_timeout]
        opts[:write_timeout]     = request[:open_timeout]
      end
    end

    def proxy_options(opts)
      return unless request

      if request[:proxy]
        opts[:proxy] = {
          host: request[:proxy][:uri].host,
          port: request[:proxy][:uri].port,
          scheme: request[:proxy][:uri].scheme,
          user: request[:proxy][:user],
          password: request[:proxy][:password]
        }
      end
    end
  end
end
