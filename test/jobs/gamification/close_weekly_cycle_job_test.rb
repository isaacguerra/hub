require "test_helper"

module Gamification
  class CloseWeeklyCycleJobTest < ActiveJob::TestCase
    setup do
      @apoiador = apoiadores(:coordenador_geral_2)
      # Create points for last week
      Gamification::ActionLog.create!(
        apoiador: @apoiador,
        action_type: "test_action",
        points_awarded: 100,
        projeto_id: projetos(:default_project).id,
        created_at: 1.week.ago
      )
    end

    test "should create weekly winner and enqueue notification" do
      assert_difference "Gamification::WeeklyWinner.count", 1 do
        assert_enqueued_with(job: SendWhatsappJob) do
          CloseWeeklyCycleJob.perform_now
        end
      end

      winner = Gamification::WeeklyWinner.last
      assert_equal @apoiador, winner.apoiador
      assert_equal 100, winner.points_total
    end
  end
end
