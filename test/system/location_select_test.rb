require "application_system_test_case"

class LocationSelectTest < ApplicationSystemTestCase
  setup do
    @apoiador = apoiadores(:joao_candidato) # Admin/Candidato pode criar eventos
  end

  test "filtragem dinâmica de localização no formulário de eventos" do
    # Login
    visit login_url
    fill_in "whatsapp", with: @apoiador.whatsapp
    click_on "Continuar" # Ajustar conforme o texto do botão real

    @apoiador.reload
    fill_in "codigo", with: @apoiador.verification_code
    click_on "Verificar Código" # Ajustar conforme o texto do botão real

    # Navegar para Novo Evento
    visit new_evento_url

    # Verificar estado inicial (sem município selecionado, deve mostrar todas as regiões ou nenhuma dependendo da lógica)
    # Pela lógica atual: !municipioId -> mostra tudo.
    assert_selector "select#evento_filtro_regiao_id option", text: "Centro"
    assert_selector "select#evento_filtro_regiao_id option", text: "Região 4"

    # Selecionar Macapá
    select "Macapá", from: "evento_filtro_municipio_id"
    
    # Verificar se filtrou Regiões (Deve ter Centro, não deve ter Região 4)
    assert_selector "select#evento_filtro_regiao_id option", text: "Centro"
    assert_no_selector "select#evento_filtro_regiao_id option", text: "Região 4"

    # Selecionar Região Centro
    select "Centro", from: "evento_filtro_regiao_id"

    # Verificar se filtrou Bairros (Deve ter Centro, Perpétuo Socorro. Não deve ter Bairro 7)
    assert_selector "select#evento_filtro_bairro_id option", text: "Centro"
    assert_selector "select#evento_filtro_bairro_id option", text: "Perpétuo Socorro"
    assert_no_selector "select#evento_filtro_bairro_id option", text: "Bairro 7"

    # Mudar Município para Santana
    select "Santana", from: "evento_filtro_municipio_id"

    # Verificar se Região mudou e limpou seleção
    assert_selector "select#evento_filtro_regiao_id option", text: "Região 4"
    assert_no_selector "select#evento_filtro_regiao_id option", text: "Centro"
    
    # Verificar se Bairro resetou (pois a região selecionada "Centro" sumiu)
    # A lógica diz: se a região selecionada não for válida, reseta.
    # E se a região reseta, os bairros devem resetar/filtrar de acordo com região vazia (mostrar todos ou nenhum).
    # Se região vazia -> mostra todos os bairros (pela lógica !regiaoId).
    assert_selector "select#evento_filtro_bairro_id option", text: "Bairro 7"
  end
end
