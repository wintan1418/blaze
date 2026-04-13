module Admin
  class BaseController < ApplicationController
    layout "admin"
    before_action :authenticate_user!
    before_action :authorize_admin!

    private

    def authorize_admin!
      return if current_user&.admin?
      flash[:alert] = "Admins only."
      redirect_to root_path
    end
  end
end
