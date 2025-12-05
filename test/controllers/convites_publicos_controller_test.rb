require "test_helper"

class ConvitesPublicosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @convite = convites(:convite_pendente)
  end

  test "deve acessar convite publico sem login" do
    get aceitar_convite_url(@convite.id)
    assert_response :success
  end

  test "deve redirecionar para login se convite nao existe" do
    get aceitar_convite_url(id: 999999)
    assert_redirected_to login_path
    assert_equal "Convite não encontrado.", flash[:alert]
  end

  test "deve redirecionar para login se convite ja aceito" do
    convite_aceito = convites(:convite_aceito)
    get aceitar_convite_url(convite_aceito.id)
    assert_redirected_to login_path
    assert_equal "Este convite já foi utilizado ou expirou.", flash[:alert]
  end

  test "deve aceitar convite com nome alterado" do
    novo_nome = "Carlos Alterado"

    assert_difference("Apoiador.count") do
      post aceitar_convite_path(@convite), params: {
        apoiador: {
          nome: novo_nome,
          email: "carlos@teste.com",
          municipio_id: 1,
          regiao_id: 1,
          bairro_id: 1
        }
      }
    end

    assert_redirected_to sucesso_convite_path

    apoiador = Apoiador.last
    assert_equal novo_nome, apoiador.name
    # O whatsapp é normalizado com 55
    assert_equal "55#{@convite.whatsapp}", apoiador.whatsapp
    assert_equal "aceito", @convite.reload.status
  end
end
