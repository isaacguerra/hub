require "test_helper"

class Mobile::GamificationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
    sign_in_as(@apoiador)
  end

  test "should get index" do
    get mobile_gamification_index_url
    assert_response :success
  end

  test "should show challenge" do
    challenge = gamification_challenges(:one)
    get mobile_gamification_url(challenge)
    assert_response :success
  end
end
