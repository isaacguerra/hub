require "test_helper"

class ComunicadosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comunicado = comunicados(:aviso_importante)
    @admin = apoiadores(:joao_candidato)
    sign_in_as(@admin)
  end

  test "should get index" do
    get comunicados_url
    assert_response :success
  end

  test "should get new" do
    get new_comunicado_url
    assert_response :success
  end

  test "should create comunicado" do
    assert_difference("Comunicado.count") do
      post comunicados_url, params: { comunicado: { mensagem: "Nova Mensagem", data: Time.current, titulo: "Novo Comunicado" } }
    end

    assert_redirected_to comunicado_url(Comunicado.last)
  end

  test "should show comunicado" do
    get comunicado_url(@comunicado)
    assert_response :success
  end

  test "should get edit" do
    get edit_comunicado_url(@comunicado)
    assert_response :success
  end

  test "should update comunicado" do
    patch comunicado_url(@comunicado), params: { comunicado: { titulo: "Título Atualizado" } }
    assert_redirected_to comunicado_url(@comunicado)
  end

  test "should destroy comunicado" do
    comunicado_to_destroy = Comunicado.create!(titulo: "To Destroy", mensagem: "Msg", data: Time.current, lider: @admin, projeto_id: projetos(:default_project).id)

    assert_difference("Comunicado.count", -1) do
      delete comunicado_url(comunicado_to_destroy)
    end

    assert_redirected_to comunicados_url
  end
end
