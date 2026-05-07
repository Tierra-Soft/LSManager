class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :require_login

  helper_method :current_admin, :logged_in?

  private

  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id])
  end

  def logged_in?
    current_admin.present?
  end

  def require_login
    redirect_to login_path, alert: "ログインが必要です" unless logged_in?
  end

  def require_super_admin
    redirect_to root_path, alert: "権限がありません" unless current_admin&.super_admin?
  end
end
