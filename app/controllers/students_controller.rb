require "csv"

class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    @students = Student.order(:name)
    if params[:q].present?
      q = "%#{params[:q]}%"
      @students = @students.where("name ILIKE ? OR email ILIKE ? OR furigana ILIKE ? OR referee_number ILIKE ?", q, q, q, q)
    end
    @students = @students.page(params[:page])
  end

  def show
    @enrollments = @student.student_course_enrollments.includes(course: :lessons)
    enrolled_course_ids = @enrollments.map(&:course_id)
    @available_courses = Course.where.not(id: enrolled_course_ids).order(:title)
    @progresses_by_course = @student.progresses
      .joins(:lesson)
      .group("lessons.course_id")
      .sum(:score)
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

  def enrollment_matrix
    @courses = Course.order(:title)
    @students = Student.order(:furigana, :name).page(params[:page]).per(25)
    @enrollments_map = StudentCourseEnrollment
      .where(student_id: @students.map(&:id))
      .each_with_object({}) { |e, h| h[[e.student_id, e.course_id]] = e.id }

    if request.patch?
      submitted = params[:enrollments]&.to_unsafe_h || {}
      Student.where(id: @students.map(&:id)).each do |student|
        student_submitted = submitted[student.id.to_s] || {}
        @courses.each do |course|
          enrolled = @enrollments_map.key?([student.id, course.id])
          should_enroll = student_submitted[course.id.to_s] == "1"
          if should_enroll && !enrolled
            student.student_course_enrollments.create!(course: course)
          elsif !should_enroll && enrolled
            student.student_course_enrollments.find_by(course: course)&.destroy
          end
        end
      end
      redirect_to enrollment_matrix_students_path(page: params[:page]), notice: "登録コースを更新しました"
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
      :affiliated_association, :skill_category, :application_qualification,
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
