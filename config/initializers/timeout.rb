if Rails.env.production?
  Rack::Timeout.timeout = 45  # seconds
end