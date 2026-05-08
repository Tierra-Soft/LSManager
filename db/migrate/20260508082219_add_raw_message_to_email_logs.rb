class AddRawMessageToEmailLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :email_logs, :raw_message, :text
  end
end
