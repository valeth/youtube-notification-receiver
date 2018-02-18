# YouTube Notification Receiver

Simple Sinatra app to receive YouTube updates from Pubsubhubub.

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

## Issues

Please report issues on the [GitLab Issue Board](https://gitlab.com/valeth/youtube-notification-receiver/issues).
