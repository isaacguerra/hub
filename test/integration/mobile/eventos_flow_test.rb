require "test_helper"

class Mobile::EventosFlowTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
    @evento = eventos(:reuniao_geral)
  end

  test "renderiza formulário mobile com atributos stimulus corretos" do
    sign_in_as(@apoiador)
    
    get new_mobile_evento_url
    assert_response :success
    
    # Verifica se o controller stimulus está conectado
    assert_select "div[data-controller='location-select']"
    
    # Verifica se os selects têm os targets e data attributes corretos
    assert_select "select#evento_filtro_municipio_id[data-location-select-target='municipio']"
    
    # Verifica containers e selects
    assert_select "div[data-location-select-target='regiaoContainer']" do
      assert_select "select#evento_filtro_regiao_id[data-location-select-target='regiao']"
    end
    
    assert_select "div[data-location-select-target='bairroContainer']" do
      assert_select "select#evento_filtro_bairro_id[data-location-select-target='bairro']"
    end
    
    # Verifica se as opções têm os data attributes de filtro
    # Macapá (id: 1)
    assert_select "select#evento_filtro_municipio_id option[value='1']", text: "Macapá"
    
    # Região Centro (id: 1, municipio_id: 1)
    assert_select "select#evento_filtro_regiao_id option[value='1'][data-municipio-id='1']"
    
    # Bairro Centro (id: 1, regiao_id: 1)
    assert_select "select#evento_filtro_bairro_id option[value='1'][data-regiao-id='1']"
  end

  test "cria evento com sucesso via mobile" do
    sign_in_as(@apoiador)

    assert_difference("Evento.count") do
      post mobile_eventos_url, params: {
        evento: {
          titulo: "Novo Evento Mobile",
          data: 1.day.from_now,
          local: "Local Teste",
          descricao: "Descrição do evento mobile",
          filtro_municipio_id: municipios(:macapa).id,
          filtro_regiao_id: regioes(:centro).id
        }
      }
    end

    assert_redirected_to mobile_eventos_url
    follow_redirect!
    assert_select "div", text: "Evento criado com sucesso."
    
    evento = Evento.last
    assert_equal "Novo Evento Mobile", evento.titulo
    assert_equal municipios(:macapa).id, evento.filtro_municipio_id
    assert_equal regioes(:centro).id, evento.filtro_regiao_id
  end

  test "exibe erros ao tentar criar evento inválido" do
    sign_in_as(@apoiador)

    assert_no_difference("Evento.count") do
      post mobile_eventos_url, params: {
        evento: {
          titulo: "", # Título vazio é inválido
          data: 1.day.from_now,
          local: "Local Teste"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "div.alert.alert-danger"
    assert_select "div", text: "Titulo não pode ficar em branco"
    
    # Verifica se o formulário foi renderizado novamente com os campos
    assert_select "input[name='evento[local]'][value='Local Teste']"
  end

  test "atualiza evento com sucesso via mobile" do
    sign_in_as(@apoiador)

    get edit_mobile_evento_url(@evento)
    assert_response :success
    assert_select "input[name='evento[titulo]'][value='#{@evento.titulo}']"

    patch mobile_evento_url(@evento), params: {
      evento: {
        titulo: "Título Atualizado",
        local: "Novo Local"
      }
    }

    assert_redirected_to mobile_eventos_url
    follow_redirect!
    assert_select "div", text: "Evento atualizado com sucesso."

    @evento.reload
    assert_equal "Título Atualizado", @evento.titulo
    assert_equal "Novo Local", @evento.local
  end
end
