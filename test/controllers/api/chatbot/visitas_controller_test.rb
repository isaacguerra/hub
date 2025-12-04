require "test_helper"

class Api::Chatbot::VisitasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @visita = visitas(:visita_pendente)
    @lider_id = @visita.lider_id
  end

  test "should list visitas for lider" do
    get api_chatbot_visitas_url, params: { apoiador_id: @lider_id }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response["visitas"]
    assert_equal @lider_id, json_response["visitas"].first["lider_id"]
  end

  test "should return bad request without apoiador_id" do
    get api_chatbot_visitas_url, as: :json
    assert_response :bad_request
  end
end
