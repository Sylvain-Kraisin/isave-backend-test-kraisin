class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |error|
    render_error(status: :not_found, code: "not_found", message: generic_message(error, fallback: "Resource not found"))
  end

  rescue_from ActiveRecord::RecordInvalid do |error|
    render_validation_errors(error.record)
  end

  rescue_from ActionController::ParameterMissing do |error|
    render_error(status: :bad_request, code: "bad_request", message: generic_message(error, fallback: "Missing required parameter"))
  end

  private

  def render_error(status:, code:, message: nil, meta: nil)
    body = { error: { code: code, message: message, status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status] } }
    body[:error][:meta] = meta if meta
    render json: body, status: status
  end

  def render_validation_errors(record)
    errors = record.errors.to_hash(true)
    render json: { error: { code: "validation_error", message: "Validation failed", status: 422, details: errors } }, status: :unprocessable_entity
  end

  def generic_message(error, fallback: "Error")
    Rails.env.production? ? fallback : error.message
  end
end
