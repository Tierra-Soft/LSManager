class AddScheduledAtToEmailLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :email_logs, :scheduled_at, :datetime
  end
end
