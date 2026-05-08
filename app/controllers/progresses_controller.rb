class ProgressesController < ApplicationController
  before_action :set_student

  def index
    @enrollments = @student.student_course_enrollments.includes(course: :lessons)
    @progresses = @student.progresses.index_by(&:lesson_id)
  end

  def create
    lesson = Lesson.find(params[:progress][:lesson_id])
    @progress = @student.progresses.find_or_initialize_by(lesson: lesson)
    @progress.score = params[:progress][:score].to_i
    if @progress.save
      redirect_to student_progresses_path(@student), notice: "進捗を更新しました"
    else
      redirect_to student_progresses_path(@student), alert: "更新に失敗しました"
    end
  end

  def update
    @progress = @student.progresses.find(params[:id])
    if @progress.update(score: params[:progress][:score].to_i)
      redirect_to student_progresses_path(@student), notice: "進捗を更新しました"
    else
      redirect_to student_progresses_path(@student), alert: "更新に失敗しました"
    end
  end

  private

  def set_student
    @student = Student.find(params[:student_id])
  end
end
