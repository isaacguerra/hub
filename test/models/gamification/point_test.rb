require "test_helper"

class Gamification::PointTest < ActiveSupport::TestCase
  setup do
    @apoiador = apoiadores(:coordenador_geral_2)
  end

  test "should be valid" do
    point = Gamification::Point.new(apoiador: @apoiador, points: 10, level: 1)
    assert point.valid?
  end

  test "should require points" do
    point = Gamification::Point.new(apoiador: @apoiador, level: 1)
    point.points = nil
    assert_not point.valid?
  end

  test "should require level" do
    point = Gamification::Point.new(apoiador: @apoiador, points: 10)
    point.level = nil
    assert_not point.valid?
  end
end
