module V1
  class TimeLogsController < ApplicationController
    before_action :set_time_log, only: %i[ show update destroy ]

    def index
      @time_logs = params.key?(:user_id) ? TimeLog.where(user_id: params[:user_id]) : TimeLog.all
    end

    def show; end

    def create
      @time_log = TimeLog.new(create_time_log_params)

      if @time_log.save
        render :show, status: :created, location: v1_time_register_url(@time_log)
      else
        render json: { errors: @time_log.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      if @time_log.update(update_time_log_params)
        render :show, status: :ok, location: v1_time_register_url(@time_log)
      else
        render json: { errors: @time_log.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy = @time_log.destroy!

    private

    def set_time_log
      @time_log = TimeLog.find(params.expect(:id))
    end

    def create_time_log_params = params.expect(time_register: %i[ user_id clock_in clock_out ])
    def update_time_log_params = params.require(:time_register).permit(:clock_in, :clock_out)
  end
end
