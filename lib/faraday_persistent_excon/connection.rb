module FaradayPersistentExcon
  class Connection
    attr_accessor :excon
    attr_accessor :last_use
    attr_accessor :idle_timeout

    def initialize(excon:, idle_timeout:)
      @excon = excon
      @idle_timeout = idle_timeout
    end

    def reset
      excon.reset
    end

    def expired?
      return false if last_use.nil?

      Time.now.utc - last_use > idle_timeout
    end

    def used!
      self.last_use = Time.now.utc
    end
  end
end
