# frozen_string_literal: true

require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
libdir = File.join(File.dirname(ENV["BUNDLE_GEMFILE"]), "app")
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

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
