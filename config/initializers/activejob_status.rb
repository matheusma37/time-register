ActiveJob::Status.store = :redis_cache_store, { url: ENV["REDIS_URL"] }
ActiveJob::Status.options = {
  expires_in: 1.day.to_i,
  throttle_interval: 0.1
}
