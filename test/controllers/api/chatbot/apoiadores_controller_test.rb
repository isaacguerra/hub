require "test_helper"

class Api::Chatbot::ApoiadoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
  end

  test "should get apoiador by whatsapp" do
    post api_chatbot_apoiadores_url, params: { whatsapp: @apoiador.whatsapp }, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @apoiador.id, json_response["id"]
    assert_equal @apoiador.name, json_response["name"]
  end

  test "should return not found for invalid whatsapp" do
    post api_chatbot_apoiadores_url, params: { whatsapp: "00000000000" }, as: :json
    assert_response :not_found
  end

  test "should return bad request when whatsapp is missing" do
    post api_chatbot_apoiadores_url, params: {}, as: :json
    assert_response :bad_request
  end
end
