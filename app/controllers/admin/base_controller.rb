module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin
    helper_method :current_admin

    private

    def current_admin
      return @current_admin if defined?(@current_admin)

      @current_admin = User.active.admin.find_by(id: session[:user_id])
    end

    def require_admin
      return if current_admin

      reset_session
      redirect_to admin_login_path, alert: "Iniciá sesión como administrador para continuar."
    end
  end
end
