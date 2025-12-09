require "test_helper"

class Gamification::BadgeTest < ActiveSupport::TestCase
  test "should be valid" do
    badge = Gamification::Badge.new(key: "test_badge", name: "Test Badge", description: "A test badge")
    assert badge.valid?
  end

  test "should require key" do
    badge = Gamification::Badge.new(name: "Test Badge")
    assert_not badge.valid?
  end

  test "should require name" do
    badge = Gamification::Badge.new(key: "test_badge")
    assert_not badge.valid?
  end

  test "should enforce unique key" do
    Gamification::Badge.create!(key: "unique_badge", name: "Unique Badge")
    duplicate = Gamification::Badge.new(key: "unique_badge", name: "Duplicate Badge")
    assert_not duplicate.valid?
  end
end
