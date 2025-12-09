require "test_helper"

class Gamification::ActionLogTest < ActiveSupport::TestCase
  setup do
    @apoiador = apoiadores(:joao_candidato)
  end

  test "should be valid" do
    log = Gamification::ActionLog.new(apoiador: @apoiador, action_type: "test_action", points_awarded: 10)
    assert log.valid?
  end

  test "should require action_type" do
    log = Gamification::ActionLog.new(apoiador: @apoiador, points_awarded: 10)
    assert_not log.valid?
  end

  test "should require points_awarded" do
    log = Gamification::ActionLog.new(apoiador: @apoiador, action_type: "test_action")
    log.points_awarded = nil
    assert_not log.valid?
  end
end
