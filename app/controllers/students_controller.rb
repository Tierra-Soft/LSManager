require "csv"

class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    @students = Student.order(:name)
    @students = @students.where("name LIKE ? OR email LIKE ? OR student_code LIKE ?",
                                "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @students = @students.where(status: params[:status]) if params[:status].present?
    @students = @students.page(params[:page])
  end

  def show
    @enrollments = @student.student_course_enrollments.includes(:course)
    @recent_progresses = @student.progresses.includes(lesson: :course).order(updated_at: :desc).limit(10)
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    if @student.save
      redirect_to @student, notice: "受講者を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: "受講者情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: "受講者を削除しました"
  end

  def import
    if request.post?
      if params[:file].blank?
        redirect_to import_students_path, alert: "ファイルを選択してください"
        return
      end
      result = Student.import_csv(params[:file])
      if result[:errors].empty?
        redirect_to students_path, notice: "#{result[:imported]}件の受講者データをインポートしました"
      else
        @errors = result[:errors]
        @imported = result[:imported]
        render :import
      end
    end
  end

  def export_csv
    students = Student.order(:student_code)
    csv_data = CSV.generate(encoding: "UTF-8", headers: true) do |csv|
      csv << %w[student_code name email department enrolled_on status]
      students.each do |s|
        csv << [s.student_code, s.name, s.email, s.department, s.enrolled_on, s.status]
      end
    end
    send_data "﻿#{csv_data}", filename: "students_#{Date.today}.csv", type: "text/csv"
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :email, :student_code, :department, :enrolled_on, :status)
  end
end
