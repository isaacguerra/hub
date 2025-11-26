require "test_helper"

module Mobile
  class VisitasControllerTest < ActionDispatch::IntegrationTest
    setup do
      @lider = apoiadores(:pedro_lider)
      @apoiador = apoiadores(:ana_apoiadora)
      @visita = visitas(:visita_pendente)
      sign_in_as(@lider)
    end

    test "should get index" do
      get mobile_visitas_url
      assert_response :success
    end

    test "should get new" do
      get new_mobile_visita_url
      assert_response :success
    end

    test "should create visita" do
      assert_difference("Visita.count") do
        post mobile_visitas_url, params: { visita: { apoiador_id: @apoiador.id, status: "pendente", relato: "Nova visita mobile" } }
      end

      assert_redirected_to mobile_visitas_url
    end

    test "should get edit" do
      get edit_mobile_visita_url(@visita)
      assert_response :success
    end

    test "should update visita" do
      patch mobile_visita_url(@visita), params: { visita: { relato: "Relato atualizado mobile" } }
      assert_redirected_to mobile_visitas_url
    end

    test "should destroy visita" do
      assert_difference("Visita.count", -1) do
        delete mobile_visita_url(@visita)
      end

      assert_redirected_to mobile_visitas_url
    end
  end
end
