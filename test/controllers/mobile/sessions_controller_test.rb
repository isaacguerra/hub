require "test_helper"

module Mobile
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @apoiador = apoiadores(:joao_candidato)
    end

    test "should login with magic link" do
      @apoiador.gerar_codigo_acesso!
      code = @apoiador.verification_code

      get magic_link_url(code)

      assert_redirected_to mobile_dashboard_path
      assert_equal @apoiador.id, session[:apoiador_id]
    end

    test "should fail with invalid magic link" do
      get magic_link_url("invalid_code")

      assert_redirected_to login_path
      assert_nil session[:apoiador_id]
    end

    test "should logout" do
      sign_in_as(@apoiador)
      delete mobile_logout_url

      assert_redirected_to login_path
      assert_nil session[:apoiador_id]
    end
  end
end
