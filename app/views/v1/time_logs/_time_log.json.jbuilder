json.extract! time_log, :id, :user_id, :clock_in, :clock_out, :created_at, :updated_at
json.url v1_time_log_url(time_log, format: :json)
