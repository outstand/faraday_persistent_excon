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

      opts
    end
  end
end
