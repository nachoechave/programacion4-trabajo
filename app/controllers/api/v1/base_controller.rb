module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Recurso no encontrado" }, status: :not_found
      end

      private

      attr_reader :current_api_user

      def authenticate_api_user!
        header = request.authorization.to_s
        raw = header.match(/\ABearer ([a-f0-9]{64})\z/)&.captures&.first
        digest = Digest::SHA256.hexdigest(raw) if raw
        @api_token = ApiToken.valid_now.includes(:user).find_by(token_digest: digest) if digest
        @current_api_user = @api_token&.user if @api_token&.user&.active?
        return if @current_api_user

        render json: { error: "Token ausente, inválido o vencido" }, status: :unauthorized
      end

      def require_api_admin!
        return if current_api_user.admin?

        render json: { error: "Permisos insuficientes" }, status: :forbidden
      end
    end
  end
end
