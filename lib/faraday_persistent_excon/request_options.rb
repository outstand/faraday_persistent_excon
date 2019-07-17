module FaradayPersistentExcon
  class RequestOptions

    def call(env)
      opts = FaradayPersistentExcon.excon_options.dup

      if env[:url].scheme == 'https' && ssl = env[:ssl]
        opts[:ssl_verify_peer] = !!ssl.fetch(:verify, true)
        opts[:ssl_ca_path] = ssl[:ca_path] if ssl[:ca_path]
        opts[:ssl_ca_file] = ssl[:ca_file] if ssl[:ca_file]
        opts[:client_cert] = ssl[:client_cert] if ssl[:client_cert]
        opts[:client_key]  = ssl[:client_key]  if ssl[:client_key]
        opts[:certificate] = ssl[:certificate] if ssl[:certificate]
        opts[:private_key] = ssl[:private_key] if ssl[:private_key]
        opts[:ssl_version] = ssl[:version] if ssl[:version]
        opts[:ssl_min_version] = ssl[:min_version] if ssl[:min_version]
        opts[:ssl_max_version] = ssl[:max_version] if ssl[:max_version]
      end

      if ( req = env[:request] )
        if req[:timeout]
          opts[:read_timeout]      = req[:timeout]
          opts[:connect_timeout]   = req[:timeout]
          opts[:write_timeout]     = req[:timeout]
        end

        if req[:open_timeout]
          opts[:connect_timeout]   = req[:open_timeout]
        end

        if req[:proxy]
          opts[:proxy] = {
            host: req[:proxy][:uri].host,
            hostname: req[:proxy][:uri].hostname,
            port: req[:proxy][:uri].port,
            scheme: req[:proxy][:uri].scheme,
            user: req[:proxy][:user],
            password: req[:proxy][:password]
          }
        end
      end

      if FaradayPersistentExcon.retry_idempotent_methods && FaradayPersistentExcon.idempotent_methods.include?(env[:method].to_s.upcase)
        opts[:idempotent] = true
      end

      opts
    end
  end
end
