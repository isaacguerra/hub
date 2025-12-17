require "test_helper"

module Gamification
  class AnnounceWinnerJobTest < ActiveJob::TestCase
    setup do
      @challenge = gamification_challenges(:one)
      @apoiador = apoiadores(:joao_candidato)
      # Ensure challenge has a winner
      Gamification::ChallengeParticipant.find_or_create_by!(challenge: @challenge, apoiador: @apoiador) do |p|
        p.points = 100
        p.projeto_id = projetos(:default_project).id
      end
      @challenge.update!(winner: @apoiador) unless @challenge.winner_id == @apoiador.id
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
