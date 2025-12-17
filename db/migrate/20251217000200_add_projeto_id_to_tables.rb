class AddProjetoIdToTables < ActiveRecord::Migration[8.1]
  def change
    # principais
    unless column_exists?(:apoiadores, :projeto_id)
      add_reference :apoiadores, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:eventos, :projeto_id)
      add_reference :eventos, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:convites, :projeto_id)
      add_reference :convites, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:comunicados, :projeto_id)
      add_reference :comunicados, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:visitas, :projeto_id)
      add_reference :visitas, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:linkpaineis, :projeto_id)
      add_reference :linkpaineis, :projeto, null: false, foreign_key: true, index: true
    end

    # joins (id: false tables)
    unless column_exists?(:apoiadores_eventos, :projeto_id)
      add_column :apoiadores_eventos, :projeto_id, :integer, null: false
      add_index :apoiadores_eventos, :projeto_id
      add_foreign_key :apoiadores_eventos, :projetos, column: :projeto_id
    end

    unless column_exists?(:comunicado_apoiadores, :projeto_id)
      add_column :comunicado_apoiadores, :projeto_id, :integer, null: false
      add_index :comunicado_apoiadores, :projeto_id
      add_foreign_key :comunicado_apoiadores, :projetos, column: :projeto_id
    end

    # gamification
    unless column_exists?(:gamification_points, :projeto_id)
      add_reference :gamification_points, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_action_logs, :projeto_id)
      add_reference :gamification_action_logs, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_action_weights, :projeto_id)
      add_reference :gamification_action_weights, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_apoiador_badges, :projeto_id)
      add_reference :gamification_apoiador_badges, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_challenges, :projeto_id)
      add_reference :gamification_challenges, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_challenge_participants, :projeto_id)
      add_reference :gamification_challenge_participants, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_levels, :projeto_id)
      add_reference :gamification_levels, :projeto, null: false, foreign_key: true, index: true
    end
    unless column_exists?(:gamification_weekly_winners, :projeto_id)
      add_reference :gamification_weekly_winners, :projeto, null: false, foreign_key: true, index: true
    end
  end
end
