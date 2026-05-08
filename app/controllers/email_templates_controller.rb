class EmailTemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy, :preview, :send_email]

  def index
    @templates = EmailTemplate.order(:name).page(params[:page])
  end

  def show; end

  def new
    @template = EmailTemplate.new
  end

  def create
    @template = EmailTemplate.new(template_params)
    if @template.save
      redirect_to @template, notice: "メールテンプレートを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @template.update(template_params)
      redirect_to @template, notice: "テンプレートを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to email_templates_path, notice: "テンプレートを削除しました"
  end

  def preview
    student_ids = params[:student_ids]&.reject(&:blank?)
    if student_ids.blank?
      redirect_to @template, alert: "送信対象の受講者を選択してください" and return
    end
    @students = Student.where(id: student_ids)
    @previews = @students.map do |student|
      subject, body = @template.render_for(student)
      { student: student, subject: subject, body: body }
    end
  end

  def send_email
    student_ids = params[:student_ids]&.reject(&:blank?)
    if student_ids.blank?
      redirect_to @template, alert: "送信対象の受講者を選択してください" and return
    end

    scheduled_at = parse_scheduled_at(params[:scheduled_at])
    students = Student.where(id: student_ids)
    scheduled = 0
    sent = 0
    failed = 0

    students.each do |student|
      subject, body = @template.render_for(student)
      begin
        if scheduled_at
          log = EmailLog.create!(student: student, email_template: @template,
                                 scheduled_at: scheduled_at, status: :pending)
          ScheduledEmailJob.set(wait_until: scheduled_at).perform_later(log.id)
          scheduled += 1
        else
          StudentMailer.template_email(student, subject, body).deliver_later
          EmailLog.create!(student: student, email_template: @template,
                           sent_at: Time.current, status: :sent)
          sent += 1
        end
      rescue => e
        EmailLog.create!(student: student, email_template: @template,
                         sent_at: Time.current, status: :failed, error_message: e.message)
        failed += 1
      end
    end

    if scheduled_at
      redirect_to @template, notice: "#{scheduled}件を #{I18n.l(scheduled_at, format: :short)} に送信予約しました#{failed > 0 ? "（#{failed}件失敗）" : ""}"
    else
      redirect_to @template, notice: "#{sent}件送信しました#{failed > 0 ? "（#{failed}件失敗）" : ""}"
    end
  end

  def bulk_send
    template = EmailTemplate.find(params[:email_template_id])
    scheduled_at = parse_scheduled_at(params[:scheduled_at])
    students = Student.active
    scheduled = 0
    sent = 0

    students.each do |student|
      subject, body = template.render_for(student)
      begin
        if scheduled_at
          log = EmailLog.create!(student: student, email_template: template,
                                 scheduled_at: scheduled_at, status: :pending)
          ScheduledEmailJob.set(wait_until: scheduled_at).perform_later(log.id)
          scheduled += 1
        else
          StudentMailer.template_email(student, subject, body).deliver_later
          EmailLog.create!(student: student, email_template: template,
                           sent_at: Time.current, status: :sent)
          sent += 1
        end
      rescue => e
        EmailLog.create!(student: student, email_template: template,
                         sent_at: Time.current, status: :failed, error_message: e.message)
      end
    end

    if scheduled_at
      redirect_to email_templates_path, notice: "アクティブ受講者#{scheduled}件を #{I18n.l(scheduled_at, format: :short)} に送信予約しました"
    else
      redirect_to email_templates_path, notice: "アクティブ受講者#{sent}件にメールを送信しました"
    end
  end

  private

  def set_template
    @template = EmailTemplate.find(params[:id])
  end

  def template_params
    params.require(:email_template).permit(:name, :subject, :body, :category)
  end

  def parse_scheduled_at(value)
    return nil if value.blank?
    time = Time.zone.parse(value)
    time.future? ? time : nil
  rescue ArgumentError
    nil
  end
end
