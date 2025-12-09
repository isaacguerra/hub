require "test_helper"

module Gamification
  class LevelTest < ActiveSupport::TestCase
    test "should be valid with valid attributes" do
      level = Level.new(level: 100, experience_threshold: 100000)
      assert level.valid?
    end

    test "should require level" do
      level = Level.new(experience_threshold: 100)
      assert_not level.valid?
    end

    test "should require experience_threshold" do
      level = Level.new(level: 100)
      assert_not level.valid?
    end

    test "should enforce uniqueness of level" do
      Level.create!(level: 101, experience_threshold: 100)
      duplicate = Level.new(level: 101, experience_threshold: 200)
      assert_not duplicate.valid?
    end

    test "should clear cache after commit" do
      Rails.cache.write("gamification_levels", { 1 => 100 })
      Level.create!(level: 102, experience_threshold: 200)
      assert_nil Rails.cache.read("gamification_levels")
    end
  end
end
