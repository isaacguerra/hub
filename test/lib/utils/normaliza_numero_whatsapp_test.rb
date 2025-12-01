require "test_helper"
require "utils/normaliza_numero_whatsapp"

class NormalizaNumeroWhatsappTest < ActiveSupport::TestCase
  test "deve formatar numeros corretamente" do
    # Caso 1: 8 dígitos
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("91120579")
    
    # Caso 2: 9 dígitos
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("991120579")
    
    # Caso 3: 10 dígitos (DDD + 8)
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("9691120579")
    
    # Caso 3b: 11 dígitos (DDD + 9)
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("96991120579")
    
    # Caso 4: 12 dígitos com 55 (DDI + DDD + 8 digitos)
    # Exemplo: 55 + 11 + 91120579 -> 5511991120579
    assert_equal "5511991120579", Utils::NormalizaNumeroWhatsapp.format("551191120579")
    
    # Caso 4b: Fixture (55 + 96 + 99100001) -> 5596999100001
    # Nota: O fixture tem 8 digitos (99100001) apos o DDD 96? 
    # Se 99100001 tem 8 digitos, entao vira 999100001.
    assert_equal "5596999100001", Utils::NormalizaNumeroWhatsapp.format("559699100001")

    # Caso 5: 13 dígitos completo 5596...
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("5596991120579")
    
    # Caso 6: 13 dígitos outro DDD
    assert_equal "5511991120579", Utils::NormalizaNumeroWhatsapp.format("5511991120579")
    
    # Com formatação
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("(96) 99112-0579")
    
    # Com zero inicial
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("096991120579")
  end
end
