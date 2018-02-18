# frozen_string_literal: true

require "logging"

# TODO: figure out how Sinatra handles logging

Logging.color_scheme("bright",
  levels: {
    info: :green,
    warn: :yellow,
    error: :red,
    fatal: %i[white on_red]
  },
  date: :blue,
  logger: :cyan,
  message: :magenta
)

Logging.appenders.stdout(
  "stdout",
  layout: Logging.layouts.pattern(
    pattern: "[%-5l] %d : %m\n",
    color_scheme: "bright"
  )
)

LOGGER = Logging.logger.root
LOGGER.level = :debug
LOGGER.appenders = :stdout
