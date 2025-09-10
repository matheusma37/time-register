class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    render json: { errors: [ e.message ] }, status: :internal_server_error
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: [ e.message ] }, status: :not_found
  end
end
