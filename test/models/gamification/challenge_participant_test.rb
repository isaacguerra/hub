require "test_helper"

class Gamification::ChallengeParticipantTest < ActiveSupport::TestCase
  setup do
    @apoiador = apoiadores(:joao_candidato)
    @challenge = Gamification::Challenge.create!(
      title: "Test Challenge",
      description: "Test Description",
      reward: "Test Reward",
      starts_at: Time.current,
      ends_at: 1.week.from_now
    )
  end

  test "should be valid" do
    participant = Gamification::ChallengeParticipant.new(
      challenge: @challenge,
      apoiador: @apoiador
    )
    assert participant.valid?
  end

  test "should enforce uniqueness" do
    Gamification::ChallengeParticipant.create!(challenge: @challenge, apoiador: @apoiador)
    duplicate = Gamification::ChallengeParticipant.new(challenge: @challenge, apoiador: @apoiador)
    assert_not duplicate.valid?
  end
end
