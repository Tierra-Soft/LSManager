class AdminsController < ApplicationController
  before_action :require_super_admin, except: [:show, :edit, :update]
  before_action :set_admin, only: [:show, :edit, :update, :destroy]

  def index
    @admins = Admin.order(:name).page(params[:page])
  end

  def show; end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    if @admin.save
      redirect_to admins_path, notice: "管理者を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to root_path, alert: "権限がありません" unless current_admin.super_admin? || current_admin == @admin
  end

  def update
    unless current_admin.super_admin? || current_admin == @admin
      redirect_to root_path, alert: "権限がありません" and return
    end
    if @admin.update(admin_params)
      redirect_to admins_path, notice: "管理者情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @admin == current_admin
      redirect_to admins_path, alert: "自分自身は削除できません" and return
    end
    @admin.destroy
    redirect_to admins_path, notice: "管理者を削除しました"
  end

  private

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def admin_params
    permitted = [:name, :email, :password, :password_confirmation]
    permitted << :role if current_admin&.super_admin?
    params.require(:admin).permit(permitted)
  end
end
