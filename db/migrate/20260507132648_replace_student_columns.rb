class ReplaceStudentColumns < ActiveRecord::Migration[8.1]
  def change
    # 既存カラムを削除
    remove_column :students, :student_code
    remove_column :students, :department
    remove_column :students, :enrolled_on
    remove_column :students, :status

    # 新カラムを追加
    add_column :students, :association,               :string   # 所属協会
    add_column :students, :skill_category,            :string   # 技能区分
    add_column :students, :application_qualification, :string   # 申込時資格
    add_column :students, :reception_number,          :string   # 受付整理番号
    add_column :students, :referee_number,            :string   # 審判登録番号
    add_column :students, :furigana,                  :string   # フリガナ
    add_column :students, :date_of_birth,             :date     # 生年月日
    add_column :students, :category,                  :string   # カテゴリー
    add_column :students, :gender,                    :string   # 性別
    add_column :students, :postal_code,               :string   # 住所（〒）
    add_column :students, :prefecture,                :string   # 住所（都道府県）
    add_column :students, :city,                      :string   # 住所（市区郡）
    add_column :students, :address_detail,            :string   # 住所（町名・番地）
    add_column :students, :phone_home,                :string   # 電話（自宅）
    add_column :students, :phone_work,                :string   # 電話（勤務先）
    add_column :students, :phone_mobile,              :string   # 電話（携帯）
    add_column :students, :fax_type,                  :string   # ファックス区分
    add_column :students, :fax,                       :string   # ファックス
    add_column :students, :seminar_number,            :string   # 講習会・研修会番号
    add_column :students, :application_method,        :string   # 申込方法
    add_column :students, :application_date,          :date     # 申込日
    add_column :students, :payment_status,            :string   # 支払状況
    add_column :students, :payment_amount,            :integer  # 支払金額
    add_column :students, :payment_method,            :string   # 支払方法
    add_column :students, :payment_due_date,          :date     # 支払期限
    add_column :students, :payment_completed_date,    :date     # 支払完了日
    add_column :students, :attendance,                :string   # 出欠
    add_column :students, :result,                    :string   # 結果
    add_column :students, :pass_processed_date,       :date     # 合格処理日
    add_column :students, :promotion_processed_date,  :date     # 昇級認定処理日
    add_column :students, :jfa_id,                    :string   # JFAID
    add_column :students, :comment,                   :text     # コメント
  end
end
