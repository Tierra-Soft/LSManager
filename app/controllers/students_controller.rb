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
      if params[:confirm]
        # Step 2: 確認後にインポート実行
        tmp_path = session.delete(:csv_tmp_path)
        if tmp_path.blank? || !File.exist?(tmp_path)
          redirect_to import_students_path, alert: "セッションが切れました。再度アップロードしてください"
          return
        end
        result = Student.import_csv_from_path(tmp_path)
        File.delete(tmp_path) rescue nil
        if result[:errors].empty?
          redirect_to students_path, notice: "#{result[:imported]}件の受講者データをインポートしました"
        else
          @errors = result[:errors]
          @imported = result[:imported]
          render :import
        end
      else
        # Step 1: アップロード→プレビュー表示
        if params[:file].blank?
          redirect_to import_students_path, alert: "ファイルを選択してください"
          return
        end
        tmp_path = Rails.root.join("tmp", "csv_import_#{SecureRandom.hex(8)}.csv")
        FileUtils.cp(params[:file].path, tmp_path)
        session[:csv_tmp_path] = tmp_path.to_s

        @preview_headers, @preview_rows, @total_rows = parse_csv_preview(tmp_path)
        render :import_preview
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

  def parse_csv_preview(path)
    headers = nil
    rows = []
    total = 0
    CSV.foreach(path, headers: true, encoding: "UTF-8:UTF-8") do |row|
      headers ||= row.headers
      rows << row.fields if rows.size < 5
      total += 1
    end
    [headers || [], rows, total]
  rescue
    [[], [], 0]
  end

  def student_params
    params.require(:student).permit(:name, :email, :student_code, :department, :enrolled_on, :status)
  end
end
