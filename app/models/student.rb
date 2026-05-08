class Student < ApplicationRecord
  has_many :student_course_enrollments, dependent: :destroy
  has_many :courses, through: :student_course_enrollments
  has_many :progresses, dependent: :destroy
  has_many :email_logs, dependent: :destroy

  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  CSV_COLUMNS = {
    "所属協会"         => :affiliated_association,
    "技能区分"         => :skill_category,
    "申込時資格"       => :application_qualification,
    "受付整理番号"     => :reception_number,
    "審判登録番号"     => :referee_number,
    "氏名"             => :name,
    "フリガナ"         => :furigana,
    "生年月日"         => :date_of_birth,
    "カテゴリー"       => :category,
    "性別"             => :gender,
    "住所（〒）"       => :postal_code,
    "住所（都道府県）" => :prefecture,
    "住所（市区郡）"   => :city,
    "住所（町名・番地）" => :address_detail,
    "電話（自宅）"     => :phone_home,
    "電話（勤務先）"   => :phone_work,
    "電話（携帯）"     => :phone_mobile,
    "ファックス区分"   => :fax_type,
    "ファックス"       => :fax,
    "メールアドレス"   => :email,
    "講習会・研修会番号" => :seminar_number,
    "申込方法"         => :application_method,
    "申込日"           => :application_date,
    "支払状況"         => :payment_status,
    "支払金額"         => :payment_amount,
    "支払方法"         => :payment_method,
    "支払期限"         => :payment_due_date,
    "支払完了日"       => :payment_completed_date,
    "出欠"             => :attendance,
    "結果"             => :result,
    "合格処理日"       => :pass_processed_date,
    "昇級認定処理日"   => :promotion_processed_date,
    "JFAID"            => :jfa_id,
    "コメント"         => :comment
  }.freeze

  def self.import_csv_from_path(path)
    errors = []
    imported = 0
    CSV.foreach(path, headers: true, encoding: "UTF-8:UTF-8") do |row|
      attrs = {}
      CSV_COLUMNS.each do |col_name, field|
        attrs[field] = row[col_name] if row.headers.include?(col_name)
      end
      email = attrs[:email].to_s.strip
      next if email.blank?

      student = find_or_initialize_by(email: email)
      student.assign_attributes(attrs)
      if student.save
        imported += 1
      else
        errors << "行 #{$.}: #{student.errors.full_messages.join(', ')}"
      end
    end
    { imported: imported, errors: errors }
  rescue CSV::MalformedCSVError => e
    { imported: 0, errors: ["CSVフォーマットエラー: #{e.message}"] }
  end

  def self.import_csv(file)
    import_csv_from_path(file.path)
  end
end
