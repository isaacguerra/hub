class AddPerformanceIndicesAndCounterCache < ActiveRecord::Migration[8.1]
  def up
    # 1. Index for login lookup
    add_index :apoiadores, :whatsapp, unique: true unless index_exists?(:apoiadores, :whatsapp)

    # 2. Index for leaderboard sorting
    add_index :gamification_points, :points unless index_exists?(:gamification_points, :points)

    # 3. Index for log filtering
    add_index :gamification_action_logs, :created_at unless index_exists?(:gamification_action_logs, :created_at)

    # 4. Counter cache column
    add_column :apoiadores, :subordinados_count, :integer, default: 0, null: false

    # Backfill counter cache
    # We need to reset column information to ensure the new column is visible
    Apoiador.reset_column_information

    puts "Updating subordinados_count for all Apoiadores..."
    Apoiador.find_each do |apoiador|
      Apoiador.reset_counters(apoiador.id, :subordinados)
    end
  end

  def down
    remove_column :apoiadores, :subordinados_count
    remove_index :gamification_action_logs, :created_at
    remove_index :gamification_points, :points
    remove_index :apoiadores, :whatsapp
  end
end
