# YouTube Notification Receiver

Simple Sinatra app to receive YouTube updates from Pubsubhubub.

---

## Installation

Make sure you have a *redis* server installed.

Alternatively, if you have *Docker* and *docker-compose*, just run
`docker-compose up -d redis` in the project root and you should be set.

First run `bundle install` to install ruby dependencies.

This might require some additional development headers for your system.

Secondly, copy `.env.example` to `.env` and set the config keys if necessary.

Key               | Options
----------------- | -----------------------
`APP_ENV`         | *development*, *production*
`REDIS_URL`       | Redis URL schema
`WEBSUB_CALLBACK` | The URL under which this server should be reachable
`YOUTUBE_API_KEY` | YouTube Data API key

If you set everything, just run `rackup config.ru`.

---

## Usage

> Note: `$WEBSUB_CALLBACK` can be localhost when the server is run locally

### Subscription

```sh
GET $WEBSUB_CALLBACK/youtube/subscribe/<youtube-channel-id>
GET $WEBSUB_CALLBACK/youtube/unsubscribe/<youtube-channel-id>
```

This will send a subscription request to the Google Pubsubhubbub server
and request the actual channel name as well if possible.

A subscription will last about 6 days before renewal is required.
You can renew subscriptions prematurely, it will just extend the current one.

On successful subscription you will receive following JSON response:

```json
{
  "channel_id":   "<youtube-channel-id>",
  "channel_name": "<channel-name> or empty string"
}
```

### Manual notification

```sh
POST $WEBSUB_CALLBACK/youtube
```

The payload needs to be a valid [YouTube Atom feed][youtube_push_notifs].

### Notifications

Notifications will be published on the `youtube_updates` channel through Redis.

They have following JSON format:

```json
{
  "author":             "<youtube-channel-name>",
  "title":              "<video-title>",
  "url":                "<video-url>",
  "youtube_channel_id": "<youtube-channel-id>",
  "youtube_video_id":   "<youtube-video-id>",
  "thumbnail_url":      "<video-thumbnail>",
  "description":        "<video-description> or empty",
  "published":          "ISO8601 timestamp",
  "updated":            "ISO8601 timestamp"
}
```

## Issues

Please report issues on the [GitLab Issue Board](https://gitlab.com/valeth/youtube-notification-receiver/issues).

[youtube_push_notifs]: https://developers.google.com/youtube/v3/guides/push_notifications