require "test_helper"

class Api::Chatbot::ConvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lider = apoiadores(:joao_candidato)
  end

  test "should create convite" do
    assert_difference("Convite.count") do
      post api_chatbot_convites_url, params: { 
        lider_id: @lider.id, 
        whatsapp: "5596999998888", 
        nome: "Novo Convidado" 
      }, as: :json
    end

    assert_response :created
  end

  test "should not create convite with existing whatsapp" do
    # Create a user first to simulate existing whatsapp
    existing_apoiador = apoiadores(:coordenador_geral_1)
    
    assert_no_difference("Convite.count") do
      post api_chatbot_convites_url, params: { 
        lider_id: @lider.id, 
        whatsapp: existing_apoiador.whatsapp, 
        nome: "Duplicado" 
      }, as: :json
    end

    assert_response :conflict
  end

  test "should return bad request when params are missing" do
    post api_chatbot_convites_url, params: { lider_id: @lider.id }, as: :json
    assert_response :bad_request
  end

  test "should list convites for lider" do
    # Ensure there are convites for this leader
    Convite.create!(enviado_por_id: @lider.id, whatsapp: "5596999997777", nome: "Convidado Teste", status: "pendente")

    get api_chatbot_convites_url, params: { lider_id: @lider.id }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_empty json_response["convites"]
    assert_equal @lider.id, json_response["convites"].first["lider_id"]
  end
end
