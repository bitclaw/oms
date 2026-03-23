# frozen_string_literal: true

# Configure Rails cache store and Action Cable to use Redis if REDIS_URL is present.
if ENV["REDIS_URL"]
  Rails.application.config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"], namespace: "aceup:cache" }

  # Action Cable (if used)
  if defined?(ActionCable)
    Rails.application.config.action_cable.url = ENV["REDIS_URL"]
    Rails.application.config.action_cable.allowed_request_origins = [ /http:\/\/localhost:\d+/ ]
    Rails.application.config.action_cable.cable = { adapter: "redis", url: ENV["REDIS_URL"] }
  end
end
