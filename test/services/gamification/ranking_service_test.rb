require "test_helper"

class Gamification::RankingServiceTest < ActiveSupport::TestCase
  setup do
    @apoiador1 = apoiadores(:joao_candidato)
    @apoiador2 = apoiadores(:maria_coord_geral)
    Gamification::ActionLog.destroy_all
  end

  test "deve retornar ranking correto" do
    # Apoiador 1: 20 pontos hoje
    Gamification::ActionLog.create!(
      apoiador: @apoiador1,
      action_type: "test",
      points_awarded: 20,
      projeto_id: projetos(:default_project).id,
      created_at: Time.current
    )

    # Apoiador 2: 50 pontos hoje
    Gamification::ActionLog.create!(
      apoiador: @apoiador2,
      action_type: "test",
      points_awarded: 50,
      projeto_id: projetos(:default_project).id,
      created_at: Time.current
    )

    ranking = Gamification::RankingService.top_apoiadores(period: :daily)
    
    assert_equal 2, ranking.size
    assert_equal @apoiador2, ranking.first[:apoiador] # Vencedor
    assert_equal 50, ranking.first[:points]
    assert_equal @apoiador1, ranking.second[:apoiador]
    assert_equal 20, ranking.second[:points]
  end

  test "deve respeitar o período de tempo" do
    # Ação ontem (não deve contar para daily)
    Gamification::ActionLog.create!(
      apoiador: @apoiador1,
      action_type: "test",
      points_awarded: 100,
      projeto_id: projetos(:default_project).id,
      created_at: 1.day.ago
    )

    ranking = Gamification::RankingService.top_apoiadores(period: :daily)
    assert_empty ranking
    
    # Mas deve aparecer no weekly
    ranking_weekly = Gamification::RankingService.top_apoiadores(period: :weekly)
    assert_not_empty ranking_weekly
  end
end
