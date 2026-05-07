class CreateEmailLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :email_logs do |t|
      t.references :student, null: false, foreign_key: true
      t.references :email_template, null: false, foreign_key: true
      t.datetime :sent_at
      t.integer :status
      t.text :error_message

      t.timestamps
    end
  end
end
