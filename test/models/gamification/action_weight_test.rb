require "test_helper"

module Gamification
  class ActionWeightTest < ActiveSupport::TestCase
    test "should be valid with valid attributes" do
      weight = ActionWeight.new(action_type: "test_action", points: 10, description: "Test")
      assert weight.valid?
    end

    test "should require action_type" do
      weight = ActionWeight.new(points: 10)
      assert_not weight.valid?
    end

    test "should require points" do
      weight = ActionWeight.new(action_type: "test_action")
      assert_not weight.valid?
    end

    test "should enforce uniqueness of action_type" do
      ActionWeight.create!(action_type: "unique_action", points: 10, projeto_id: projetos(:default_project).id)
      duplicate = ActionWeight.new(action_type: "unique_action", points: 20)
      assert_not duplicate.valid?
    end

    test "should clear cache after commit" do
      Rails.cache.write("gamification_weights", { "test" => 1 })
      ActionWeight.create!(action_type: "new_action", points: 5, projeto_id: projetos(:default_project).id)
      assert_nil Rails.cache.read("gamification_weights")
    end
  end
end
