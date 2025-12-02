require "test_helper"

module Mobile
  class EventosControllerTest < ActionDispatch::IntegrationTest
    setup do
      @evento = eventos(:reuniao_geral)
      @admin = apoiadores(:joao_candidato)
      sign_in_as(@admin)
    end

    test "should get index" do
      get mobile_eventos_url
      assert_response :success
    end

    test "should create evento" do
      assert_difference("Evento.count") do
        post mobile_eventos_url, params: { evento: { titulo: "Mobile Evento", data: 1.day.from_now, local: "Mobile Local", descricao: "Mobile Desc" } }
      end

      assert_redirected_to mobile_eventos_url
    end

    test "should update evento" do
      patch mobile_evento_url(@evento), params: { evento: { titulo: "Mobile Updated" } }
      assert_redirected_to mobile_eventos_url
    end
  end
end
