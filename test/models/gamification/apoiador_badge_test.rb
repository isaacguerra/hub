require "test_helper"

class Gamification::ApoiadorBadgeTest < ActiveSupport::TestCase
  setup do
    @apoiador = apoiadores(:joao_candidato)
    @badge = Gamification::Badge.create!(key: "test_badge", name: "Test Badge")
  end

  test "should be valid" do
    apoiador_badge = Gamification::ApoiadorBadge.new(apoiador: @apoiador, badge: @badge, awarded_at: Time.current)
    assert apoiador_badge.valid?
  end

  test "should enforce uniqueness" do
    Gamification::ApoiadorBadge.create!(apoiador: @apoiador, badge: @badge, projeto_id: projetos(:default_project).id)
    duplicate = Gamification::ApoiadorBadge.new(apoiador: @apoiador, badge: @badge)
    assert_not duplicate.valid?
  end
end
