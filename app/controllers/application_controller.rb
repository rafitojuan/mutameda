class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def current_user_settings
    @current_user_settings ||= current_user.user_settings.index_by(&:setting_key)
  end
  helper_method :current_user_settings

  def user_setting(key, default = nil)
    current_user_settings[key]&.setting_value || default
  end
  helper_method :user_setting

  def set_user_setting(key, value)
    current_user.set_setting(key, value)
  end

  def redirect_with_notice(path, message)
    redirect_to path, notice: message
  end

  def redirect_with_alert(path, message)
    redirect_to path, alert: message
  end

  def json_response(data, status = :ok)
    render json: data, status: status
  end

  def handle_record_not_found
    redirect_to root_path, alert: 'Record not found.'
  end

  def handle_unauthorized_access
    redirect_to root_path, alert: 'You are not authorized to access this page.'
  end
end
