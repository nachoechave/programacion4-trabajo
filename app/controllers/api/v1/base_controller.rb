module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Recurso no encontrado" }, status: :not_found
      end
    end
  end
end
