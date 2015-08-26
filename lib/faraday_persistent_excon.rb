require 'faraday'
require 'thread_safe'
require 'connection_pool'
require 'active_support'
require 'active_support/core_ext/class/attribute'

require 'faraday_persistent_excon/version'
require 'faraday_persistent_excon/perform_request'
require 'faraday_persistent_excon/adapter'
require 'faraday_persistent_excon/request_options'
require 'faraday_persistent_excon/connection_pools'
require 'faraday_persistent_excon/connection'

module FaradayPersistentExcon
  class << self
    attr_accessor :excon_options
    attr_accessor :perform_request_class
    attr_accessor :connection_pools
    attr_accessor :idempotent_methods
    attr_accessor :retry_idempotent_methods
    attr_accessor :idle_timeout
  end

  self.excon_options = {}
  self.perform_request_class = FaradayPersistentExcon::PerformRequest
  self.connection_pools = {}
  self.idempotent_methods = %w[GET HEAD PUT DELETE OPTIONS TRACE]
  self.retry_idempotent_methods = true
  self.idle_timeout = 60
end

Faraday::Adapter.register_middleware persistent_excon: ->{ FaradayPersistentExcon::Adapter }
