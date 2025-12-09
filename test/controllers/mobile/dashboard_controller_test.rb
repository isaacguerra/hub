require "test_helper"

module Mobile
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @apoiador = apoiadores(:joao_candidato)
      sign_in_as(@apoiador)
    end

    test "should get index" do
      get mobile_dashboard_url
      assert_response :success
    end
  end
end
