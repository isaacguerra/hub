require "test_helper"

class Mobile::Gamification::StrategiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
    sign_in_as(@apoiador)
    
    # Create a weekly winner record for this apoiador
      @weekly_winner = Gamification::WeeklyWinner.create!(
      apoiador: @apoiador,
      week_start_date: 1.week.ago.beginning_of_week.to_date,
      week_end_date: 1.week.ago.end_of_week.to_date,
      points_total: 100,
      projeto_id: projetos(:default_project).id
    )
  end

  test "should get edit" do
    get edit_mobile_gamification_strategy_url
    assert_response :success
  end

  test "should update strategy" do
    patch mobile_gamification_strategy_url, params: { 
      id: @weekly_winner.id,
      gamification_weekly_winner: { winning_strategy: "My secret strategy" } 
    }
    assert_redirected_to mobile_dashboard_path
    
    @weekly_winner.reload
    assert_equal "My secret strategy", @weekly_winner.winning_strategy
  end
end
