# frozen_string_literal: true

require "json"
require "youtube/api"
require "youtube/notification"
require "youtube/websub"

module Youtube
  module Feed
    extend Cached

    HUB = Youtube::WebSub.new("https://pubsubhubbub.appspot.com").freeze
    CALLBACK_URL = ENV.fetch("WEBSUB_CALLBACK").freeze

  module_function

    # @param xml [String]
    # @return [nil]
    def process_item(xml)
      json = Youtube::Notification.new(xml).to_json
      redis_publish(json)
    end

    # @param json [String]
    # @return [nil]
    def redis_publish(json)
      REDIS.publish("youtube_updates", json)
      nil
    end

    # @param id [String]
    # @return [(Integer, String)]
    def subscribe(id)
      response = with_cache("#{id}_channel_title") do
        { "channel_id" => id, "channel_name" => Youtube::API.channel_title(id) }
      end

      puts response

      LOGGER.info do
        "Updating subscription for channel #{response['channel_name']} (#{id})..."
      end

      code = request(id) { |topic, callback| HUB.subscribe(topic, callback) }
      code = 200 if code == 204
      [code, response.to_json]
    rescue StandardError => e
      [500, { error: e.to_s }.to_json]
    end

    # @param id [String]
    # @return [Integer]
    def unsubscribe(id)
      request(id) { |topic, callback| HUB.unsubscribe(topic, callback) }
    end

    # @param id [String]
    # @return [Integer]
    def request(id)
      return 400 unless valid_id?(id)

      response = yield(
        "https://www.youtube.com/xml/feeds/videos.xml?channel_id=#{id}",
        CALLBACK_URL
      )

      response.code
    end

    # YouTube channel IDs are 24 characters long,
    # and consist of alphanumeric characters, dashes and underscores
    # @param id [String]
    # @return [Boolean]
    def valid_id?(id)
      /^[\w-]{24}$/.match?(id)
    end
  end
end
