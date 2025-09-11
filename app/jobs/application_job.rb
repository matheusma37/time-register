class ApplicationJob < ActiveJob::Base
  include ActiveJob::Status

  before_perform { |job| job.status[:status] = :processing }
end
