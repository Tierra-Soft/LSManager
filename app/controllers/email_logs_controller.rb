class EmailLogsController < ApplicationController
  def index
    @logs = EmailLog.includes(:student, :email_template).recent
    @logs = @logs.where(student_id: params[:student_id]) if params[:student_id].present?
    @logs = @logs.where(status: params[:status]) if params[:status].present?
    @logs = @logs.page(params[:page])
  end

  def show
    @log = EmailLog.includes(:student, :email_template).find(params[:id])
    if @log.student && @log.email_template
      @rendered_subject, @rendered_body = @log.email_template.render_for(@log.student)
    end
  end
end
