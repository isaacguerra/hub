class AddProjetoToGamificationActionLogs < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:gamification_action_logs, :projeto_id)
      add_reference :gamification_action_logs, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
