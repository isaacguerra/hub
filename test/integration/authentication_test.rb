require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:pedro_lider)
    # Ensure whatsapp is normalized in fixture or setup
    @apoiador.update(whatsapp: "5596991234567")
  end

  test "fluxo completo de login" do
    # 1. Acessa página de login
    get login_path
    assert_response :success

    # 2. Envia WhatsApp
    Mensageria::Notificacoes::Autenticacao.stub :enviar_codigo, true do
      post sessions_path, params: { whatsapp: "96991234567" }
    end
    
    assert_response :success # Renderiza verify
    assert_not_nil session[:auth_apoiador_id]
    
    # Recarrega apoiador para pegar o código gerado
    @apoiador.reload
    assert_not_nil @apoiador.verification_code
    codigo = @apoiador.verification_code

    # 3. Envia código correto
    post sessions_verify_path, params: { codigo: codigo }
    
    assert_redirected_to root_path
    assert_equal @apoiador.id, session[:apoiador_id]
    assert_nil session[:auth_apoiador_id]
    
    # Verifica se limpou o código
    @apoiador.reload
    assert_nil @apoiador.verification_code
  end

  test "login com numero invalido" do
    post sessions_path, params: { whatsapp: "00000000000" }
    assert_response :unprocessable_entity
    assert_match "Número não encontrado", response.body
  end

  test "login com codigo invalido" do
    # Setup do estado de verificação
    @apoiador.gerar_codigo_acesso!
    
    # Simula sessão iniciada na etapa 1
    # Integration tests don't allow setting session directly easily without a helper, 
    # but our controller accepts apoiador_id param as fallback or we can simulate the flow.
    
    # Vamos simular o fluxo até a verificação
    Mensageria::Notificacoes::Autenticacao.stub :enviar_codigo, true do
      post sessions_path, params: { whatsapp: "96991234567" }
    end

    post sessions_verify_path, params: { codigo: "000000" }
    assert_response :unprocessable_entity
    assert_match "Código inválido", response.body
    assert_nil session[:apoiador_id]
  end

  test "logout" do
    # Loga primeiro (simulado)
    post sessions_path, params: { whatsapp: "96991234567" }
    @apoiador.reload
    post sessions_verify_path, params: { codigo: @apoiador.verification_code }
    
    assert_not_nil session[:apoiador_id]

    # Logout
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:apoiador_id]
  end
end
