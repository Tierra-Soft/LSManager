class EmailTemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy, :send_email]

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

  def send_email
    student_ids = params[:student_ids]&.reject(&:blank?)
    if student_ids.blank?
      redirect_to @template, alert: "送信対象の受講者を選択してください" and return
    end

    students = Student.where(id: student_ids)
    sent = 0
    failed = 0

    students.each do |student|
      subject, body = @template.render_for(student)
      begin
        StudentMailer.template_email(student, subject, body).deliver_later
        EmailLog.create!(student: student, email_template: @template,
                         sent_at: Time.current, status: :sent)
        sent += 1
      rescue => e
        EmailLog.create!(student: student, email_template: @template,
                         sent_at: Time.current, status: :failed, error_message: e.message)
        failed += 1
      end
    end

    redirect_to @template, notice: "#{sent}件送信しました#{failed > 0 ? "（#{failed}件失敗）" : ""}"
  end

  def bulk_send
    template = EmailTemplate.find(params[:email_template_id])
    students = Student.active
    sent = 0

    students.each do |student|
      subject, body = template.render_for(student)
      begin
        StudentMailer.template_email(student, subject, body).deliver_later
        EmailLog.create!(student: student, email_template: template,
                         sent_at: Time.current, status: :sent)
        sent += 1
      rescue => e
        EmailLog.create!(student: student, email_template: template,
                         sent_at: Time.current, status: :failed, error_message: e.message)
      end
    end

    redirect_to email_templates_path, notice: "アクティブ受講者#{sent}件にメールを送信しました"
  end

  private

  def set_template
    @template = EmailTemplate.find(params[:id])
  end

  def template_params
    params.require(:email_template).permit(:name, :subject, :body, :category)
  end
end
