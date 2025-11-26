require "test_helper"

class ApoiadoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
    sign_in_as(@apoiador)
  end

  test "should get index" do
    get apoiadores_url
    assert_response :success
  end

  test "should show apoiador" do
    get apoiador_url(@apoiador)
    assert_response :success
  end

  test "should get edit" do
    get edit_apoiador_url(@apoiador)
    assert_response :success
  end

  test "should update apoiador" do
    patch apoiador_url(@apoiador), params: { apoiador: { nome: "Nome Atualizado" } }
    assert_redirected_to apoiador_url(@apoiador)
  end

  test "should destroy apoiador" do
    # Create a dummy apoiador to destroy, so we don't destroy the logged in user
    apoiador_to_destroy = apoiadores(:ana_apoiadora)

    assert_difference("Apoiador.count", -1) do
      delete apoiador_url(apoiador_to_destroy)
    end

    assert_redirected_to apoiadores_url
  end
end
