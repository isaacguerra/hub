require "test_helper"

class VisitasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lider = apoiadores(:pedro_lider)
    @apoiador = apoiadores(:ana_apoiadora)
    @visita = visitas(:visita_pendente)
    sign_in_as(@lider)
  end

  test "should get index" do
    get visitas_url
    assert_response :success
  end

  test "should get new" do
    get new_visita_url
    assert_response :success
  end

  test "should create visita" do
    assert_difference("Visita.count") do
      post visitas_url, params: { visita: { apoiador_id: @apoiador.id, status: "pendente", relato: "Nova visita" } }
    end

    assert_redirected_to visitas_url
  end

  test "should show visita" do
    get visita_url(@visita)
    assert_response :success
  end

  test "should get edit" do
    get edit_visita_url(@visita)
    assert_response :success
  end

  test "should update visita" do
    patch visita_url(@visita), params: { visita: { relato: "Relato atualizado" } }
    assert_redirected_to visitas_url
  end

  test "should destroy visita" do
    assert_difference("Visita.count", -1) do
      delete visita_url(@visita)
    end

    assert_redirected_to visitas_url
  end

  test "should not allow unauthorized access" do
    # Sign in as a regular apoiador who cannot manage visits
    sign_in_as(@apoiador)

    get new_visita_url
    assert_redirected_to visitas_url
    assert_equal "Você não tem permissão para registrar visitas.", flash[:alert]
  end
end
