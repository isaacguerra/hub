require "test_helper"

class BairrosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bairro = bairros(:centro_bairro)
    @regiao = @bairro.regiao
    @municipio = @regiao.municipio
    @admin = apoiadores(:joao_candidato)
    sign_in_as(@admin)
  end

  test "should get index" do
    get municipio_regiao_bairros_url(@municipio, @regiao)
    assert_response :success
  end

  test "should get new" do
    get new_municipio_regiao_bairro_url(@municipio, @regiao)
    assert_response :success
  end

  test "should create bairro" do
    assert_difference("Bairro.count") do
      post municipio_regiao_bairros_url(@municipio, @regiao), params: { bairro: { name: "Novo Bairro" } }
    end

    assert_redirected_to municipio_regiao_bairro_url(@municipio, @regiao, Bairro.last)
  end

  test "should show bairro" do
    get municipio_regiao_bairro_url(@municipio, @regiao, @bairro)
    assert_response :success
  end

  test "should get edit" do
    get edit_municipio_regiao_bairro_url(@municipio, @regiao, @bairro)
    assert_response :success
  end

  test "should update bairro" do
    patch municipio_regiao_bairro_url(@municipio, @regiao, @bairro), params: { bairro: { name: "Bairro Atualizado" } }
    assert_redirected_to municipio_regiao_bairro_url(@municipio, @regiao, @bairro)
  end

  test "should destroy bairro" do
    bairro_to_destroy = Bairro.create!(name: "To Destroy", regiao: @regiao)

    assert_difference("Bairro.count", -1) do
      delete municipio_regiao_bairro_url(@municipio, @regiao, bairro_to_destroy)
    end

    assert_redirected_to municipio_regiao_path(@municipio, @regiao)
  end
end
