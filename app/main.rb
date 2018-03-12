# frozen_string_literal: true

require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
appdir = File.join(File.dirname(ENV["BUNDLE_GEMFILE"]), "app")
$LOAD_PATH.unshift(appdir) unless $LOAD_PATH.include?(appdir)

require "dotenv"
Dotenv.load

require "bundler/setup"
require "sinatra/base"

require "utils/log"
require "utils/cache"

require "youtube/api"
require "youtube/feed"
require "youtube/notification"
require "youtube/websub"

class YoutubeNotificationReceiver < Sinatra::Application
  include Cached

  set :environment, ENV.fetch("APP_ENV", "development")

  get "/youtube/subscribe/:channel_id" do
    code, response = Youtube::Feed.subscribe(params[:channel_id])
    content_type "application/json"
    status code
    body response
  end

  get "/youtube/unsubscribe/:channel_id" do
    status Youtube::Feed.unsubscribe(params[:channel_id])
  end

  get "/youtube/search" do
    if params[:channel_name]
      response = with_cache("#{params[:channel_name]}_channel_search") do
        Youtube::API.search_channels(params[:channel_name])
      end
      content_type "application/json"
      status 200
      body response.to_json
    else
      status 400
      body "[]"
    end
  end

  get "/youtube" do
    challenge = params["hub.challenge"]
    status 200
    body challenge
  end

  post "/youtube" do
    Youtube::Feed.process_item(request.body.read)
  end

  post "/youtube/:channel_id" do
    Youtube::Feed.process_item(request.body.read)
  end
end
