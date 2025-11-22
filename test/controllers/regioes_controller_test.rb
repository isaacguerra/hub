require "test_helper"

class RegioesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regiao = regioes(:one)
  end

  test "should get index" do
    get regioes_url
    assert_response :success
  end

  test "should get new" do
    get new_regiao_url
    assert_response :success
  end

  test "should create regiao" do
    assert_difference("Regiao.count") do
      post regioes_url, params: { regiao: { municipio_id: @regiao.municipio_id, nome: @regiao.nome } }
    end

    assert_redirected_to regiao_url(Regiao.last)
  end

  test "should show regiao" do
    get regiao_url(@regiao)
    assert_response :success
  end

  test "should get edit" do
    get edit_regiao_url(@regiao)
    assert_response :success
  end

  test "should update regiao" do
    patch regiao_url(@regiao), params: { regiao: { municipio_id: @regiao.municipio_id, nome: @regiao.nome } }
    assert_redirected_to regiao_url(@regiao)
  end

  test "should destroy regiao" do
    assert_difference("Regiao.count", -1) do
      delete regiao_url(@regiao)
    end

    assert_redirected_to regioes_url
  end
end
