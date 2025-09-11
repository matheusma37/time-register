module V1
  class ReportsController < ApplicationController
    def status
      job_id = params.expect(:process_id)
      status = ActiveJob::Status.get(job_id)

      render json: { process_id: job_id, status: status.status, progress: status.progress * 100 }, status: :ok
    end

    def download
      job_id = params.expect(:process_id)
      status = ActiveJob::Status.get(job_id)

      redirect_to status.file_url, allow_other_host: true if status.completed?
    end
  end
end
