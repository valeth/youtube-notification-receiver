# frozen_string_literal: true

require "redis"
require "json"

REDIS = Redis.new(driver: :hiredis)

module Cached
  def with_cache(id)
    val = try_parse(REDIS.get(id))

    if val
      LOGGER.info { "Cache hit: #{id}" }
    else
      val = yield
      REDIS.set(id, JSON.generate(val))
      REDIS.expire(id, 172_800)
    end

    val
  end

  def try_parse(value)
    JSON.parse(value) if value
  rescue JSON::ParseError => e
    LOGGER.error { "Failed to parse JSON value: #{e}" }
    nil
  end
end
