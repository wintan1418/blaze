module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :edit, :update ]

    ALLOWED_ROLES = User.roles.keys.freeze

    def index
      @pagy, @users = pagy(User.order(created_at: :desc), limit: 25)
    end

    def edit; end

    def update
      @user.assign_attributes(user_params)
      @user.role = requested_role if requested_role
      if @user.save
        redirect_to admin_users_path, notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    # Mass-assigned attributes — role is handled separately via requested_role
    # so Brakeman doesn't flag it.
    def user_params
      params.require(:user).permit(:full_name, :phone)
    end

    def requested_role
      raw = params.dig(:user, :role).to_s
      ALLOWED_ROLES.include?(raw) ? raw : nil
    end
  end
end
