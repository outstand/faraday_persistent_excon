module FaradayPersistentExcon
  class Adapter < Faraday::Adapter
    dependency 'excon'

    def call(env)
      super
      perform_request env
      @app.call env
    end

    protected

    def perform_request(env)
      response = FaradayPersistentExcon.perform_request_class.new.call env
      save_response(
        env,
        response.status.to_i,
        response.body,
        response.headers,
        response.reason_phrase
      )
    end
  end
end
