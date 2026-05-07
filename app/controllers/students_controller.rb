require "csv"

class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    @students = Student.order(:name)
    if params[:q].present?
      q = "%#{params[:q]}%"
      @students = @students.where("name LIKE ? OR email LIKE ? OR furigana LIKE ? OR referee_number LIKE ?", q, q, q, q)
    end
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
    students = Student.order(:name)
    csv_data = CSV.generate(encoding: "UTF-8", headers: true) do |csv|
      csv << Student::CSV_COLUMNS.keys
      students.each do |s|
        csv << Student::CSV_COLUMNS.values.map { |f| s.send(f) }
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
    params.require(:student).permit(
      :name, :email, :furigana, :date_of_birth, :gender,
      :association, :skill_category, :application_qualification,
      :reception_number, :referee_number, :category,
      :postal_code, :prefecture, :city, :address_detail,
      :phone_home, :phone_work, :phone_mobile, :fax_type, :fax,
      :seminar_number, :application_method, :application_date,
      :payment_status, :payment_amount, :payment_method,
      :payment_due_date, :payment_completed_date,
      :attendance, :result, :pass_processed_date,
      :promotion_processed_date, :jfa_id, :comment
    )
  end
end
