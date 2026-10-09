module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_api_user!, only: :create

      def create
        user = User.active.find_by(email: params[:email].to_s.strip.downcase)
        unless user&.authenticate(params[:password].to_s)
          return render json: { error: "Credenciales inválidas" }, status: :unauthorized
        end

        token = ApiToken.issue!(user: user)
        render json: { token: token, token_type: "Bearer", expires_in: 24.hours.to_i }, status: :created
      end

      def destroy
        @api_token.destroy!
        head :no_content
      end
    end
  end
end
