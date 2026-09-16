module Admin
  class SessionsController < ApplicationController
    layout "admin"
    helper_method :current_admin

    def new
      redirect_to admin_root_path if current_admin
    end

    def create
      user = User.find_by(email: params[:email].to_s.strip.downcase)

      if user&.authenticate(params[:password]) && user.admin? && user.active?
        reset_session
        session[:user_id] = user.id
        redirect_to admin_root_path, notice: "Sesión iniciada correctamente."
      else
        flash.now[:alert] = "Email o contraseña incorrectos, o usuario sin acceso administrativo."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session
      redirect_to admin_login_path, notice: "Sesión cerrada."
    end

    private

    def current_admin
      return @current_admin if defined?(@current_admin)

      @current_admin = User.active.admin.find_by(id: session[:user_id])
    end
  end
end
