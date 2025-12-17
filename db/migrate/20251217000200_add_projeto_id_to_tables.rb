class AddProjetoIdToTables < ActiveRecord::Migration[8.1]
  def change
    # principais
    add_reference :apoiadores, :projeto, null: false, foreign_key: true, index: true
    add_reference :eventos, :projeto, null: false, foreign_key: true, index: true
    add_reference :convites, :projeto, null: false, foreign_key: true, index: true
    add_reference :comunicados, :projeto, null: false, foreign_key: true, index: true
    add_reference :visitas, :projeto, null: false, foreign_key: true, index: true
    add_reference :linkpaineis, :projeto, null: false, foreign_key: true, index: true

    # joins (id: false tables)
    add_column :apoiadores_eventos, :projeto_id, :integer, null: false
    add_index :apoiadores_eventos, :projeto_id
    add_foreign_key :apoiadores_eventos, :projetos, column: :projeto_id

    add_column :comunicado_apoiadores, :projeto_id, :integer, null: false
    add_index :comunicado_apoiadores, :projeto_id
    add_foreign_key :comunicado_apoiadores, :projetos, column: :projeto_id

    # gamification
    add_reference :gamification_points, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_action_logs, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_action_weights, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_apoiador_badges, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_challenges, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_challenge_participants, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_levels, :projeto, null: false, foreign_key: true, index: true
    add_reference :gamification_weekly_winners, :projeto, null: false, foreign_key: true, index: true
  end
end
