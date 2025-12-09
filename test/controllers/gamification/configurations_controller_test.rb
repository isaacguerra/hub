require "test_helper"

module Gamification
  class ConfigurationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @weight = gamification_action_weights(:convite_sent)
      @level = gamification_levels(:level_1)
      sign_in_as(apoiadores(:joao_candidato))
    end

    test "should get index" do
      get gamification_configurations_url
      assert_response :success
    end

    test "should update weight" do
      patch update_weight_gamification_configuration_url(@weight), params: { gamification_action_weight: { points: 20 } }
      assert_redirected_to gamification_configurations_url
      @weight.reload
      assert_equal 20, @weight.points
    end

    test "should update level" do
      patch update_level_gamification_configuration_url(@level), params: { gamification_level: { experience_threshold: 200 } }
      assert_redirected_to gamification_configurations_url
      @level.reload
      assert_equal 200, @level.experience_threshold
    end

    test "should deny access to non-admin" do
      sign_in_as(apoiadores(:apoiador_2))
      get gamification_configurations_url
      assert_redirected_to root_url
      assert_equal "Acesso não autorizado. Apenas administradores podem acessar esta área.", flash[:alert]
    end
  end
end
