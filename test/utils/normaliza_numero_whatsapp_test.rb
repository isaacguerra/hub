require "test_helper"

class NormalizaNumeroWhatsappTest < ActiveSupport::TestCase
  # Testes para o método format
  test "format deve retornar nil se o telefone for blank" do
    assert_nil Utils::NormalizaNumeroWhatsapp.format(nil)
    assert_nil Utils::NormalizaNumeroWhatsapp.format("")
  end

  test "format deve adicionar 55969 para números com 8 dígitos" do
    # Ex: 91120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("91120579")
  end

  test "format deve adicionar 5596 para números com 9 dígitos" do
    # Ex: 991120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("991120579")
  end

  test "format deve adicionar 55 e o nono dígito para números com 10 dígitos (DDD + 8 digitos)" do
    # Ex: 9691120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("9691120579")
  end

  test "format deve adicionar 55 para números com 11 dígitos (DDD + 9 digitos)" do
    # Ex: 96991120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("96991120579")
  end

  test "format deve tratar números com 12 dígitos começando com 55 (DDI + 10 digitos?)" do
    # Lógica atual: if cleaned.length == 12 && cleaned.start_with?("55") -> return "5596#{cleaned[2..]}"
    # Ex: 5591120579 -> 559691120579 (Nota: o código original adiciona 5596 + resto, mas se o resto tem 10 digitos, fica estranho.
    # Vamos seguir a implementação atual: cleaned[2..] pega os ultimos 10.
    # Se entrada é 55991120579 (11 digitos) -> length 11 cai no caso anterior.
    # Se entrada é 55 + 10 digitos (ex: 55 91 1234 5678) = 12 digitos.
    # O código faz: "5596" + "9112345678".

    # Testando conforme implementação:
    input = "559112345678" # 12 digitos
    expected = "5591912345678"
    assert_equal expected, Utils::NormalizaNumeroWhatsapp.format(input)
  end

  test "format deve manter números com 13 dígitos começando com 5596" do
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("5596991120579")
  end

  test "format deve manter números com 13 dígitos começando com 55 (outro DDD)" do
    # Ex: 5511991120579
    assert_equal "5511991120579", Utils::NormalizaNumeroWhatsapp.format("5511991120579")
  end

  test "format deve limpar caracteres não numéricos" do
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("(96) 99112-0579")
  end

  test "format deve remover zero inicial" do
    # Ex: 096991120579 -> 96991120579 (11 digitos) -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format("096991120579")
  end

  # Testes para o método format_chatbot_number
  test "format_chatbot_number deve retornar nil se blank" do
    assert_nil Utils::NormalizaNumeroWhatsapp.format_chatbot_number(nil)
  end

  test "format_chatbot_number deve remover sufixo @c.us ou @g.us" do
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("5596991120579@c.us")
  end

  test "format_chatbot_number deve tratar 8 dígitos (sem nono digito, sem DDD)" do
    # 91120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("91120579")
  end

  test "format_chatbot_number deve tratar 9 dígitos (com nono digito, sem DDD)" do
    # 991120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("991120579")
  end

  test "format_chatbot_number deve tratar 10 dígitos (DDD + 8 digitos)" do
    # 9691120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("9691120579")
  end

  test "format_chatbot_number deve tratar 11 dígitos (DDD + 9 digitos)" do
    # 96991120579 -> 5596991120579
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("96991120579")
  end

  test "format_chatbot_number deve tratar 12 dígitos (DDI + 10 digitos - sem DDD?)" do
    # O código diz: numero = "5596#{numero[2..]}"
    # Se entrada for 55 91120579 (10 digitos uteis) -> 559691120579
    # Mas espera, se for DDI(55) + 8 digitos = 10 digitos total.
    # Se for DDI(55) + 9 digitos = 11 digitos total.
    # Se for 12 digitos, pode ser DDI(55) + DDD(XX) + 8 digitos.
    # Ex: 55 11 9112 0579.
    # O código faz: "5596" + "1191120579". Fica estranho.
    # Vamos testar o comportamento atual implementado.
    input = "551191120579"
    expected = "55961191120579" # Comportamento atual do código
    # O format final vai pegar isso (14 digitos) e cair no "else" do format?
    # O format não tem else explicito para > 13 digitos, ele vai caindo...
    # Se cleaned.length == 14.
    # start_with?("5596") -> sim. cleaned = cleaned[4..] -> "1191120579" (10 digitos).
    # Garante 9 digitos? Nao.
    # Retorna "5596" + "1191120579" = "55961191120579".

    # Vamos testar um caso que faça sentido para a regra "DDI + número sem DDD" (talvez DDI + 9 digitos + algo?)
    # O comentário diz: "DDI + número sem DDD (raro, mas cobre)".
    # Se o numero for 55 + 991120579 (11 digitos) -> cai no case 11.
    # Se o numero for 55 + 91120579 (10 digitos) -> cai no case 10.

    # Vamos assumir que o teste deve garantir o que está codado.
    assert_equal "5511991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("551191120579")
  end

  test "format_chatbot_number deve tratar 13 dígitos (formato completo)" do
    assert_equal "5596991120579", Utils::NormalizaNumeroWhatsapp.format_chatbot_number("5596991120579")
  end

  test "format_chatbot_number deve forçar 5596 se 13 dígitos não começar com 5596" do
    # O código diz: numero.start_with?("5596") ? numero : "5596#{numero[-9..]}"
    # Ex: 5511991120579 (começa com 5511)
    # Deve pegar os ultimos 9: 991120579 e prefixar 5596 -> 5596991120579
    input = "5511991120579"
    expected = "5596991120579"
    assert_equal expected, Utils::NormalizaNumeroWhatsapp.format_chatbot_number(input)
  end
end
