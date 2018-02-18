# frozen_string_literal: true

require "json"
require "active_support/core_ext/hash/keys"
require "feedjira"
require "utils/cache"
require "youtube/api"

module Youtube
  class Notification
    include Cached

    DEFAULTS = {
      author:             "",
      published:          DateTime.now,
      title:              "",
      updated:            DateTime.now,
      url:                "",
      youtube_channel_id: "",
      youtube_video_id:   "",
      thumbnail_url:      "",
      description:        ""
    }.freeze

    # @param xml [String]
    def initialize(xml)
      @attributes = DEFAULTS.dup

      from_xml(xml)
      from_api(@attributes[:youtube_video_id])
    end

    # @return [String]
    def to_json
      JSON.generate(@attributes)
    end

  private

    def from_xml(xml)
      entry = Feedjira.parse(xml).entries.first
      @attributes.update(entry.to_h.symbolize_keys)
    rescue Feedjira::NoParserAvailable => e
      LOGGER.error { "Failed to parse feed: #{e}" }
    end

    def from_api(video_id)
      video_info = with_cache("#{video_id}_video_info") do
        Youtube::API.video_info(video_id)
      end
      @attributes.update(video_info)
    end
  end
end
