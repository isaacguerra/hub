require "test_helper"
require "minitest/mock"

module Utils
  class BuscaPerfilWhatsappTest < ActiveSupport::TestCase
    setup do
      @original_cache_store = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      @numero = "5511999999999"
      Rails.cache.clear
      @original_env = ENV.to_hash
      ENV["EVOLUTION_HOST"] = "https://localhost:8080"
      ENV["EVOLUTION_AUTHENTICATION_API_KEY"] = "test_key"
    end

    teardown do
      Rails.cache = @original_cache_store
      ENV.replace(@original_env)
    end

    test "should fetch from API on first call and cache result" do
      # Use a real Net::HTTPSuccess object to pass is_a?(Net::HTTPSuccess) check
      response_mock = Net::HTTPSuccess.new(1.0, '200', 'OK')
      # Stub body method on the instance
      def response_mock.body
        { id: "5511999999999", name: "Test User", picture: "http://pic.url" }.to_json
      end

      http_mock = Minitest::Mock.new
      http_mock.expect :use_ssl=, true, [ true ]
      http_mock.expect :request, response_mock, [ Net::HTTP::Post ]

      # We need to stub Net::HTTP.new to return our http_mock
      Net::HTTP.stub :new, http_mock do
        # First call
        result1 = Utils::BuscaPerfilWhatsapp.buscar(@numero)
        assert_equal "Test User", result1[:name]

        # Second call - should be cached
        assert Rails.cache.exist?("whatsapp_profile:#{@numero}")
        
        # Call again
        result2 = Utils::BuscaPerfilWhatsapp.buscar(@numero)
        assert_equal "Test User", result2[:name]
      end
      
      http_mock.verify
    end

    test "should return nil if API fails" do
      response_mock = Net::HTTPInternalServerError.new(1.0, '500', 'Error')
      def response_mock.body; "Error"; end

      http_mock = Minitest::Mock.new
      http_mock.expect :use_ssl=, true, [ true ]
      http_mock.expect :request, response_mock, [ Net::HTTP::Post ]

      Net::HTTP.stub :new, http_mock do
        result = Utils::BuscaPerfilWhatsapp.buscar(@numero)
        assert_nil result
      end
    end
  end
end
