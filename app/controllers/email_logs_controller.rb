class EmailLogsController < ApplicationController
  def index
    @logs = EmailLog.includes(:student, :email_template).recent
    @logs = @logs.where(student_id: params[:student_id]) if params[:student_id].present?
    @logs = @logs.where(status: params[:status]) if params[:status].present?
    @logs = @logs.page(params[:page])
  end

  def show
    @log = EmailLog.includes(:student, :email_template).find(params[:id])
  end
end
