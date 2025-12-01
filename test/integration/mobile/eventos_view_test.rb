require "test_helper"

class Mobile::EventosViewTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
    @evento = eventos(:reuniao_geral)
  end

  test "view do formulário contém estrutura correta para o stimulus controller" do
    sign_in_as(@apoiador)
    get new_mobile_evento_url
    
    assert_response :success
    
    # 1. Verifica o Controller Wrapper
    assert_select "div[data-controller='location-select']", 1
    
    # 2. Verifica Município (Gatilho Principal)
    assert_select "select#evento_filtro_municipio_id" do
      assert_select "[data-location-select-target='municipio']"
      assert_select "[data-action='change->location-select#filterRegioes']"
      # Verifica se tem a opção prompt com valor vazio
      assert_select "option[value='']", text: "Todos os Municípios"
    end

    # 3. Verifica Container e Select de Região
    assert_select "div[data-location-select-target='regiaoContainer']" do
      assert_select "select#evento_filtro_regiao_id" do
        assert_select "[data-location-select-target='regiao']"
        assert_select "[data-action='change->location-select#filterBairros']"
        # Verifica se as opções têm o data-municipio-id
        assert_select "option[data-municipio-id]", minimum: 1
      end
    end

    # 4. Verifica Container e Select de Bairro
    assert_select "div[data-location-select-target='bairroContainer']" do
      assert_select "select#evento_filtro_bairro_id" do
        assert_select "[data-location-select-target='bairro']"
        # Verifica se as opções têm o data-regiao-id
        assert_select "option[data-regiao-id]", minimum: 1
      end
    end
  end
end
