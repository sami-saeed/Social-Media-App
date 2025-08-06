class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
   before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    # For account update
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
    # For sign in
     devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
