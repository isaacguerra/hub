ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all
    fixtures :municipios, :regioes, :bairros, :funcoes, :apoiadores, :convites, :visitas, :eventos, :comunicados

    # Add more helper methods to be used by all tests here...
  end

  class ActionDispatch::IntegrationTest
    def sign_in_as(apoiador)
      # Simulate the login flow
      post sessions_url, params: { whatsapp: apoiador.whatsapp }

      # We need to reload to get the generated code
      apoiador.reload

      post sessions_verify_url, params: { apoiador_id: apoiador.id, codigo: apoiador.verification_code }
    end
  end
end
