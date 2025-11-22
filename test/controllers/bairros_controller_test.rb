require "test_helper"

class BairrosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bairro = bairros(:one)
  end

  test "should get index" do
    get bairros_url
    assert_response :success
  end

  test "should get new" do
    get new_bairro_url
    assert_response :success
  end

  test "should create bairro" do
    assert_difference("Bairro.count") do
      post bairros_url, params: { bairro: { nome: @bairro.nome, regiao_id: @bairro.regiao_id } }
    end

    assert_redirected_to bairro_url(Bairro.last)
  end

  test "should show bairro" do
    get bairro_url(@bairro)
    assert_response :success
  end

  test "should get edit" do
    get edit_bairro_url(@bairro)
    assert_response :success
  end

  test "should update bairro" do
    patch bairro_url(@bairro), params: { bairro: { nome: @bairro.nome, regiao_id: @bairro.regiao_id } }
    assert_redirected_to bairro_url(@bairro)
  end

  test "should destroy bairro" do
    assert_difference("Bairro.count", -1) do
      delete bairro_url(@bairro)
    end

    assert_redirected_to bairros_url
  end
end
