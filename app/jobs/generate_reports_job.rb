require "csv"

class GenerateReportsJob < ApplicationJob
  queue_as :generate_reports

  def perform(user_id, start_date, end_date)
    user = User.find(user_id)
    time_logs = user.time_logs.where(
      "clock_in::DATE >= ?::DATE AND (clock_out IS NULL OR clock_out::DATE <= ?::DATE)",
      Date.parse(start_date), Date.parse(end_date)
    ).order(clock_in: :asc)

    progress.total = time_logs.count + 1

    csv = generate_csv(user, time_logs)
    blob = generate_blob(csv)
    file_url = generate_file_url(blob)
    status[:file_url] = file_url
    progress.increment
  end

  private

  def generate_csv(user, time_logs)
    CSV.generate(headers: true) do |csv|
      csv << %w[User_ID Name Email Clock_In Clock_Out]

      time_logs.each do |time_log|
        csv << [
          user.id,
          user.name,
          user.email,
          time_log.clock_in.iso8601(3),
          time_log.clock_out&.iso8601(3)
        ]
        progress.increment
      end
    end
  end

  def generate_blob(csv_data)
    file = Tempfile.new([ "time_registers", ".csv" ])
    file.write(csv_data)
    file.rewind

    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: "time_registers-#{Time.current.to_i}.csv",
      content_type: "text/csv"
    )

    file.close
    file.unlink

    blob
  end

  def generate_file_url(blob)
    Rails.application.routes.url_helpers.rails_blob_url(
      blob,
      disposition: "attachment",
      only_path: false,
      expires_in: 1.day
    )
  end
end
