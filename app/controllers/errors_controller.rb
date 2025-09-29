class ErrorsController < ApplicationController
  def not_found
    render_error(status: :not_found, code: "not_found", message: "Route not found")
  end
end



