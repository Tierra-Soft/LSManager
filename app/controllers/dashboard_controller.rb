class DashboardController < ApplicationController
  def index
    @total_students = Student.count
    @active_students = Student.count
    @total_courses = Course.published.count
    @recent_email_logs = EmailLog.includes(:student, :email_template).recent.limit(10)
    @progress_stats = {
      completed: Progress.completed.count,
      in_progress: Progress.in_progress.count,
      not_started: Progress.not_started.count
    }
  end
end
