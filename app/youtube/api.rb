# frozen_string_literal: true

require "google/apis/youtube_v3"

module Youtube
  module API
    YoutubeV3 = Google::Apis::YoutubeV3
    @client = YoutubeV3::YouTubeService.new
    @client.key = ENV.fetch("YOUTUBE_API_KEY")

  module_function

    # Get thumbnails with highest possible resolution
    # @param [Youtube::ThumbnailDetails]
    # @return [String, nil]
    def youtube_thumbnail(thumbs)
      (thumbs.maxres || thumbs.standard || thumbs.high || thumbs.medium || thumbs.default)&.url
    end

    # @param video_id [String]
    # @return [Hash]
    def video_info(video_id)
      LOGGER.info { "Fetching video info for #{video_id}" }
      results = @client.list_videos("snippet", id: video_id)
      snippet = results.items.first&.snippet
      return {} unless snippet
      {
        title:         snippet.title,
        thumbnail_url: youtube_thumbnail(snippet.thumbnails),
        description:   snippet.description
      }
    rescue Google::Apis::Error => e
      LOGGER.error { "Failed to fetch YouTube video info: #{e}" }
      {}
    end

    # @param channel_id [String]
    # @return [String]
    def channel_title(channel_id)
      LOGGER.info { "Fetching channel name for #{channel_id}" }
      results = @client.list_searches("snippet", type: "channel", channel_id: channel_id)
      results.items.first&.snippet&.title || ""
    rescue Google::Apis::Error => e
      LOGGER.error { "Failed to fetch YouTube channel name: #{e}" }
      ""
    end
  end
end
