module Staff
  class BaseController < ApplicationController
    layout "staff"
    before_action :authenticate_user!
    before_action :authorize_staff!

    private

    def authorize_staff!
      return if current_user&.staff_or_admin?
      flash[:alert] = "Staff access only."
      redirect_to root_path
    end
  end
end
