class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_site_setting

  helper_method :site_setting

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  attr_reader :site_setting

  protected

  def load_site_setting
    @site_setting = SiteSetting.current
  rescue StandardError
    @site_setting = SiteSetting.new
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name, :phone ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name, :phone ])
  end

  def user_not_authorized
    flash[:alert] = "You're not allowed to do that."
    redirect_back(fallback_location: root_path)
  end
end
