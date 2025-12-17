require "test_helper"

class Gamification::BadgeServiceTest < ActiveSupport::TestCase
  setup do
    @apoiador = apoiadores(:joao_candidato)
    Gamification::ActionLog.destroy_all
    Gamification::ApoiadorBadge.destroy_all
    
    # Cria uma badge de teste
    @badge = Gamification::Badge.create!(
      key: "test_badge",
      name: "Test Badge",
      criteria: { "action_type" => "test_action", "count" => 3 }
    )
  end

  test "deve conceder badge quando critério é atingido" do
    # Cria 3 logs de ação
    3.times do
      Gamification::ActionLog.create!(
        apoiador: @apoiador,
        action_type: "test_action",
        points_awarded: 10,
        projeto_id: projetos(:default_project).id
      )
    end

    new_badges = Gamification::BadgeService.check_and_award_badges(@apoiador)
    
    assert_includes new_badges, @badge
    assert @apoiador.gamification_badges.include?(@badge)
  end

  test "não deve conceder badge se critério não for atingido" do
    # Cria apenas 2 logs (precisa de 3)
    2.times do
      Gamification::ActionLog.create!(
        apoiador: @apoiador,
        action_type: "test_action",
        points_awarded: 10,
        projeto_id: projetos(:default_project).id
      )
    end

    new_badges = Gamification::BadgeService.check_and_award_badges(@apoiador)
    
    assert_empty new_badges
    assert_not @apoiador.gamification_badges.include?(@badge)
  end

  test "não deve conceder badge repetida" do
    # Já possui a badge
    Gamification::ApoiadorBadge.create!(apoiador: @apoiador, badge: @badge, awarded_at: 1.day.ago, projeto_id: projetos(:default_project).id)

    # Tem ações suficientes
    3.times do
      Gamification::ActionLog.create!(
        apoiador: @apoiador,
        action_type: "test_action",
        points_awarded: 10,
        projeto_id: projetos(:default_project).id
      )
    end

    new_badges = Gamification::BadgeService.check_and_award_badges(@apoiador)
    
    assert_empty new_badges
  end
end
