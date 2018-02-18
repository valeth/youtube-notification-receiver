# frozen_string_literal: true

require "active_support/core_ext/hash/deep_merge"
require "nokogiri"
require "json"
require "utils/cache"
require "youtube/api"

module Youtube
  class Notification
    include Cached

    # @param xml [String]
    def initialize(xml)
      @attributes = {
        title: "",
        id: "",
        url: "",
        published: DateTime.now,
        updated: DateTime.now,
        channel: { name: "", id: "" },
        thumbnail_url: "",
        description: ""
      }

      from_xml(xml)
      from_api(@attributes[:id])
    end

    # @return [String]
    def to_json
      JSON.generate(@attributes)
    end

  private

    # @param xml [String]
    def from_xml(xml)
      doc = Nokogiri::XML(xml)
      entry = doc.at("entry")
      return unless entry
      @attributes.deep_merge!(parse_form(entry))
    end

    # @param video_id [String]
    def from_api(video_id)
      video_info = with_cache("#{video_id}_video_info") do
        Youtube::API.video_info(video_id)
      end
      @attributes.deep_merge!(video_info)
    end

    # @param date_str [String]
    # @return [DateTime, nil]
    def parse_date(date_str)
      DateTime.parse(date_str) unless date_str.empty?
    end

    # @param xml [Nokogiri::XML::Node]
    # @return [Hash]
    def parse_form(xml)
      {
        title:     xml.css("title").text,
        id:        xml.xpath("yt:videoId").text,
        url:       xml.css("link[rel='alternate']").attribute("href").value,
        published: parse_date(xml.css("published").text),
        updated:   parse_date(xml.css("updated").text),
        channel:   {
          name: xml.css("author > name").text,
          id:   xml.xpath("yt:channelId").text
        }
      }
    end
  end
end
