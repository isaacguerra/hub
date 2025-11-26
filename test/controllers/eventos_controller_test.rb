require "test_helper"

class EventosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @evento = eventos(:reuniao_geral)
    @admin = apoiadores(:joao_candidato)
    sign_in_as(@admin)
  end

  test "should get index" do
    get eventos_url
    assert_response :success
  end

  test "should get new" do
    get new_evento_url
    assert_response :success
  end

  test "should create evento" do
    assert_difference("Evento.count") do
      post eventos_url, params: { evento: { coordenador_id: @admin.id, data: 3.days.from_now, descricao: "Novo Evento", local: "Local", titulo: "Novo Evento" } }
    end

    assert_redirected_to evento_url(Evento.last)
  end

  test "should show evento" do
    get evento_url(@evento)
    assert_response :success
  end

  test "should get edit" do
    get edit_evento_url(@evento)
    assert_response :success
  end

  test "should update evento" do
    patch evento_url(@evento), params: { evento: { titulo: "Título Atualizado" } }
    assert_redirected_to evento_url(@evento)
  end

  test "should destroy evento" do
    evento_to_destroy = Evento.create!(titulo: "To Destroy", data: 1.day.from_now, coordenador: @admin)

    assert_difference("Evento.count", -1) do
      delete evento_url(evento_to_destroy)
    end

    assert_redirected_to eventos_url
  end
end
