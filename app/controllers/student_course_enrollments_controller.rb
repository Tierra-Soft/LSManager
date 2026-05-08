class StudentCourseEnrollmentsController < ApplicationController
  before_action :set_student

  def create
    course = Course.find(params[:course_id])
    enrollment = @student.student_course_enrollments.find_or_initialize_by(course: course)
    if enrollment.new_record? && enrollment.save
      redirect_to student_path(@student), notice: "「#{course.title}」に登録しました"
    else
      redirect_to student_path(@student), alert: "既に登録済みです"
    end
  end

  def destroy
    enrollment = @student.student_course_enrollments.find(params[:id])
    course_title = enrollment.course.title
    enrollment.destroy
    redirect_to student_path(@student), notice: "「#{course_title}」の登録を解除しました"
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end
end
