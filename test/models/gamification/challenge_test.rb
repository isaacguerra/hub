require "test_helper"

class Gamification::ChallengeTest < ActiveSupport::TestCase
  test "should be valid" do
    challenge = Gamification::Challenge.new(
      title: "Test Challenge",
      description: "Test Description",
      reward: "Test Reward",
      starts_at: Time.current,
      ends_at: 1.week.from_now
    )
    assert challenge.valid?
  end

  test "should require title" do
    challenge = Gamification::Challenge.new(starts_at: Time.current, ends_at: 1.week.from_now)
    assert_not challenge.valid?
  end

  test "should require dates" do
    challenge = Gamification::Challenge.new(title: "Test Challenge")
    assert_not challenge.valid?
  end
end
