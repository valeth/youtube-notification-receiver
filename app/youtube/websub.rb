# frozen_string_literal: true

require "rest-client"

module Youtube
  class WebSub
    def initialize(hub_url)
      @hub_url = hub_url
    end

    def subscribe(topic, callback, **options)
      options[:mode] = :subscribe
      request(topic, callback, options)
    end

    def unsubscribe(topic, callback, **options)
      options[:mode] = :unsubscribe
      request(topic, callback, options)
    end

  private

    def request_form(**options)
      { "hub.mode"          => options.fetch(:mode, :subscribe),
        "hub.verify"        => options.fetch(:verify, :sync),
        "hub.topic"         => options.fetch(:topic),
        "hub.lease_seconds" => options.fetch(:lease, nil),
        "hub.secret"        => options.fetch(:secret, nil),
        "hub.callback"      => options.fetch(:callback) }
    end

    def request(topic, callback, **options)
      options[:topic] = topic
      options[:callback] = callback

      RestClient.post(
        @hub_url,
        request_form(options),
        content_type: "application/x-www-form-urlencoded"
      )
    rescue RestClient::ExceptionWithResponse => e
      LOGGER.error { e.response.body }
      raise e
    end
  end
end
