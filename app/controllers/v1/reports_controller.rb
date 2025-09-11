module V1
  class ReportsController < ApplicationController
    def status
      job_id = params.expect(:process_id)
      status = ActiveJob::Status.get(job_id)

      render json: { process_id: job_id, status: status.status, progress: status.progress * 100 }, status: :ok
    end
  end
end
