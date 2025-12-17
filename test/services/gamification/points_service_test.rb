require "test_helper"

class Gamification::PointsServiceTest < ActiveSupport::TestCase
  setup do
    @apoiador = apoiadores(:joao_candidato)
    # Garante que o apoiador comece sem pontos
    Gamification::Point.destroy_all
    Gamification::ActionLog.destroy_all
  end

  test "deve atribuir pontos corretamente para ação conhecida" do
    result = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "convite_sent"
    )

    assert result[:success]
    assert_equal 2, result[:points_awarded] # Baseado no GAMIFICATION_WEIGHTS
    assert_equal 2, result[:total_points]
    
    # Verifica persistência
    point = Gamification::Point.find_by(apoiador: @apoiador)
    assert_equal 2, point.points
    assert_equal 1, point.level
  end

  test "não deve atribuir pontos para ação desconhecida" do
    result = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "acao_inexistente"
    )

    assert_not result[:success]
    assert_equal :unknown_action, result[:reason]
  end

  test "deve respeitar idempotência quando resource é fornecido" do
    # Simula um recurso (ex: um convite)
    resource = convites(:convite_pendente) # Usando fixture existente ou mock

    # Primeira chamada
    result1 = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "convite_accepted",
      resource: resource
    )
    assert result1[:success]

    # Segunda chamada com mesmo recurso
    result2 = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "convite_accepted",
      resource: resource
    )
    assert_not result2[:success]
    assert_equal :already_awarded, result2[:reason]

    # Verifica que pontos não dobraram
    point = Gamification::Point.find_by(apoiador: @apoiador)
    assert_equal 10, point.points # Peso de convite_accepted
  end

  test "deve subir de nível ao atingir pontuação necessária" do
    # Level 2 requer 100 pontos
    # Vamos dar 90 pontos primeiro
    Gamification::Point.create!(apoiador: @apoiador, points: 90, level: 1, projeto_id: projetos(:default_project).id)

    # Ação que dá 10 pontos (convite_accepted) -> Total 100 -> Level 2
    result = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "convite_accepted"
    )

    assert result[:success]
    assert result[:level_up]
    assert_equal 2, result[:level]
    assert_equal 100, result[:total_points]
  end

  test "não deve permitir login diário duplicado" do
    # Primeiro login
    result1 = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "daily_login"
    )
    assert result1[:success]

    # Segundo login no mesmo dia
    result2 = Gamification::PointsService.award_points(
      apoiador: @apoiador,
      action_type: "daily_login"
    )
    assert_not result2[:success]
    assert_equal :daily_limit_reached, result2[:reason]
  end
end
