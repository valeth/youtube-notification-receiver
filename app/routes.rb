# frozen_string_literal: true

get "/youtube" do
  challenge = params["hub.challenge"]
  status 200
  body challenge
end
