class LessonsController < ApplicationController
  before_action :set_course
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  def show; end

  def new
    @lesson = @course.lessons.new(position: @course.lessons.count + 1)
  end

  def create
    @lesson = @course.lessons.new(lesson_params)
    if @lesson.save
      redirect_to @course, notice: "レッスンを追加しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @lesson.update(lesson_params)
      redirect_to @course, notice: "レッスンを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson.destroy
    redirect_to @course, notice: "レッスンを削除しました"
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_lesson
    @lesson = @course.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title, :description, :position)
  end
end
