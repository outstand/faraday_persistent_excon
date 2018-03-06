module FaradayPersistentExcon
  class ConnectionPools
    class << self
      attr_accessor :__pools
    end
    self.__pools = ThreadSafe::Cache.new

    class << self
      def with_connection_for(url, &block)
        pool = self.connection_pool_for(url)

        if pool
          pool.with do |conn|
            begin
              conn.reset if conn.expired?
              block.call(conn.excon)
            ensure
              conn.used!
            end
          end
        else
          # No pool configured.  Use normal connection
          block.call(::Excon.new(url, persistent: false))
        end
      end

      def connection_pool_for(url)
        config = FaradayPersistentExcon.connection_pools[url]

        if config
          self.__pools.fetch_or_store(url) do
            ::ConnectionPool.new(config) do
              Connection.new(
                excon: ::Excon.new(
                  url,
                  {
                    persistent: true,
                    thread_safe_sockets: false
                  }.merge(config.fetch(:connection_options, {}))
                ),
                idle_timeout: config.fetch(:idle_timeout, FaradayPersistentExcon.idle_timeout)
              )
            end
          end
        end
      end
    end
  end
end
