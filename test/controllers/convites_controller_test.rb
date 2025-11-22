require "test_helper"

class ConvitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @convite = convites(:one)
  end

  test "should get index" do
    get convites_url
    assert_response :success
  end

  test "should get new" do
    get new_convite_url
    assert_response :success
  end

  test "should create convite" do
    assert_difference("Convite.count") do
      post convites_url, params: { convite: { enviado_por_id: @convite.enviado_por_id, nome: @convite.nome, status: @convite.status, whatsapp: @convite.whatsapp } }
    end

    assert_redirected_to convite_url(Convite.last)
  end

  test "should show convite" do
    get convite_url(@convite)
    assert_response :success
  end

  test "should get edit" do
    get edit_convite_url(@convite)
    assert_response :success
  end

  test "should update convite" do
    patch convite_url(@convite), params: { convite: { enviado_por_id: @convite.enviado_por_id, nome: @convite.nome, status: @convite.status, whatsapp: @convite.whatsapp } }
    assert_redirected_to convite_url(@convite)
  end

  test "should destroy convite" do
    assert_difference("Convite.count", -1) do
      delete convite_url(@convite)
    end

    assert_redirected_to convites_url
  end
end
