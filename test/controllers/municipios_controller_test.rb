require "test_helper"

class MunicipiosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @municipio = municipios(:macapa)
    @admin = apoiadores(:joao_candidato)
    sign_in_as(@admin)
  end

  test "should get index" do
    get municipios_url
    assert_response :success
  end

  test "should get new" do
    get new_municipio_url
    assert_response :success
  end

  test "should create municipio" do
    assert_difference("Municipio.count") do
      post municipios_url, params: { municipio: { name: "Novo Município" } }
    end

    assert_redirected_to municipio_url(Municipio.last)
  end

  test "should show municipio" do
    get municipio_url(@municipio)
    assert_response :success
  end

  test "should get edit" do
    get edit_municipio_url(@municipio)
    assert_response :success
  end

  test "should update municipio" do
    patch municipio_url(@municipio), params: { municipio: { name: "Macapá Atualizado" } }
    assert_redirected_to municipio_url(@municipio)
  end

  test "should destroy municipio" do
    # Create a dummy municipio to destroy
    municipio_to_destroy = Municipio.create!(name: "To Destroy")

    assert_difference("Municipio.count", -1) do
      delete municipio_url(municipio_to_destroy)
    end

    assert_redirected_to municipios_url
  end
end
