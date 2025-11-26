require "test_helper"

class RegioesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regiao = regioes(:centro)
    @municipio = @regiao.municipio
    @admin = apoiadores(:joao_candidato)
    sign_in_as(@admin)
  end

  test "should get index" do
    get municipio_regioes_url(@municipio)
    assert_response :success
  end

  test "should get new" do
    get new_municipio_regiao_url(@municipio)
    assert_response :success
  end

  test "should create regiao" do
    assert_difference("Regiao.count") do
      post municipio_regioes_url(@municipio), params: { regiao: { name: "Nova Região" } }
    end

    assert_redirected_to municipio_regiao_url(@municipio, Regiao.last)
  end

  test "should show regiao" do
    get municipio_regiao_url(@municipio, @regiao)
    assert_response :success
  end

  test "should get edit" do
    get edit_municipio_regiao_url(@municipio, @regiao)
    assert_response :success
  end

  test "should update regiao" do
    patch municipio_regiao_url(@municipio, @regiao), params: { regiao: { name: "Centro Atualizado" } }
    assert_redirected_to municipio_regiao_url(@municipio, @regiao)
  end

  test "should destroy regiao" do
    # Create dummy
    regiao_to_destroy = Regiao.create!(name: "To Destroy", municipio: @municipio)

    assert_difference("Regiao.count", -1) do
      delete municipio_regiao_url(@municipio, regiao_to_destroy)
    end

    assert_redirected_to municipio_path(@municipio)
  end
end
