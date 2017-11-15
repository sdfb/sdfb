if Rails.env.production?
  Rack::Timeout.timeout = 90  # seconds
end