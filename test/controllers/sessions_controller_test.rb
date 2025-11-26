require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apoiador = apoiadores(:joao_candidato)
  end

  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should send verification code" do
    # Mock the method that generates/sends code if necessary, or just rely on model logic
    # Assuming gerar_codigo_acesso! updates the model

    post sessions_url, params: { whatsapp: @apoiador.whatsapp }
    assert_redirected_to sessions_verify_url
    assert_not_nil session[:auth_apoiador_id]

    @apoiador.reload
    assert_not_nil @apoiador.verification_code
  end

  test "should verify code and login" do
    # Manually set code
    @apoiador.update(verification_code: "123456", verification_code_expires_at: 10.minutes.from_now)

    # Simulate step 1 session state
    post sessions_verify_url, params: { apoiador_id: @apoiador.id, codigo: "123456" }

    assert_redirected_to root_path # Assuming desktop user agent by default
    assert_equal @apoiador.id, session[:apoiador_id]
  end

  test "should fail with invalid whatsapp" do
    post sessions_url, params: { whatsapp: "00000000000" }
    assert_response :unprocessable_entity
    assert_equal "Número não encontrado. Verifique se digitou corretamente ou entre em contato com seu líder.", flash[:alert]
  end

  test "should fail with invalid code" do
    @apoiador.update(verification_code: "123456", verification_code_expires_at: 10.minutes.from_now)

    post sessions_verify_url, params: { apoiador_id: @apoiador.id, codigo: "000000" }
    assert_response :unprocessable_entity
    assert_equal "Código inválido ou expirado.", flash[:alert]
  end

  test "should logout" do
    sign_in_as(@apoiador)
    delete logout_url
    assert_redirected_to login_url
    assert_nil session[:apoiador_id]
  end
end
