require "test_helper"

module Gamification
  class AnnounceWinnerJobTest < ActiveJob::TestCase
    setup do
      @challenge = gamification_challenges(:one)
      @apoiador = apoiadores(:joao_candidato)
      # Ensure challenge has a winner
      Gamification::ChallengeParticipant.create!(challenge: @challenge, apoiador: @apoiador, points: 100, projeto_id: projetos(:default_project).id)
      @challenge.update!(winner: @apoiador)
    end

    test "should enqueue whatsapp messages for all apoiadores" do
      # Assuming there are apoiadores in the database
      assert Apoiador.count > 0

      assert_enqueued_with(job: SendWhatsappJob) do
        AnnounceWinnerJob.perform_now(@challenge.id)
      end
    end
  end
end
