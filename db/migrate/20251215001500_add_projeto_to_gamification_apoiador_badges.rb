class AddProjetoToGamificationApoiadorBadges < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:gamification_apoiador_badges, :projeto_id)
      add_reference :gamification_apoiador_badges, :projeto, foreign_key: false, index: true, null: true
    end
  end
end
