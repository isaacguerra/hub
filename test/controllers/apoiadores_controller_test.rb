require "test_helper"

class ApoiadoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:one)
  end

  test "should get index" do
    get apoiadores_url
    assert_response :success
  end

  test "should get new" do
    get new_apoiador_url
    assert_response :success
  end

  test "should create apoiador" do
    assert_difference("Apoiador.count") do
      post apoiadores_url, params: { apoiador: { bairro_id: @apoiador.bairro_id, email: @apoiador.email, endereco: @apoiador.endereco, funcao_id: @apoiador.funcao_id, lider_id: @apoiador.lider_id, municipio_id: @apoiador.municipio_id, nome: @apoiador.nome, regiao_id: @apoiador.regiao_id, whatsapp: @apoiador.whatsapp } }
    end

    assert_redirected_to apoiador_url(Apoiador.last)
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
    patch apoiador_url(@apoiador), params: { apoiador: { bairro_id: @apoiador.bairro_id, email: @apoiador.email, endereco: @apoiador.endereco, funcao_id: @apoiador.funcao_id, lider_id: @apoiador.lider_id, municipio_id: @apoiador.municipio_id, nome: @apoiador.nome, regiao_id: @apoiador.regiao_id, whatsapp: @apoiador.whatsapp } }
    assert_redirected_to apoiador_url(@apoiador)
  end

  test "should destroy apoiador" do
    assert_difference("Apoiador.count", -1) do
      delete apoiador_url(@apoiador)
    end

    assert_redirected_to apoiadores_url
  end
end
