json.extract! time_log, :id, :user_id, :clock_in, :clock_out, :created_at, :updated_at
json.url v1_time_register_url(time_log, format: :json)
