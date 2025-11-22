require "test_helper"

module Api
  class PaineisControllerTest < ActionDispatch::IntegrationTest
    setup do
      ENV['BASE_URL'] = "http://localhost:3000"
      @apoiador = apoiadores(:pedro_lider)
    end

    test "deve retornar link para whatsapp válido" do
      get api_painel_url, params: { whatsapp: @apoiador.whatsapp, real_ip: "127.0.0.1" }
      
      assert_response :success
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["url"]
      assert_includes json_response["url"], "http"
    end

    test "deve retornar erro para whatsapp inválido" do
      get api_painel_url, params: { whatsapp: "00000000000" }
      
      assert_response :not_found
      json_response = JSON.parse(response.body)
      assert_equal "Apoiador não encontrado", json_response["error"]
    end

    test "deve retornar erro sem whatsapp" do
      get api_painel_url
      
      assert_response :bad_request
      json_response = JSON.parse(response.body)
      assert_equal "Whatsapp é obrigatório", json_response["error"]
    end
  end
end
