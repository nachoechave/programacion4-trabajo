module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update]

    def index
      @users = User.order(:name)
    end

    def show; end

    def new
      @user = User.new(role: :analyst, active: true)
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_user_path(@user), notice: "Usuario creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attributes = user_params
      attributes.delete(:password) if attributes[:password].blank?
      attributes.delete(:password_confirmation) if attributes[:password_confirmation].blank?

      if @user.update(attributes)
        redirect_to admin_user_path(@user), notice: "Usuario actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      attributes = params.require(:user).permit(:name, :email, :password, :password_confirmation)
      requested_role = params[:user][:role]
      attributes[:role] = requested_role if User.roles.key?(requested_role)
      if params[:user].key?(:active)
        attributes[:active] = ActiveModel::Type::Boolean.new.cast(params[:user][:active])
      end
      attributes
    end
  end
end
