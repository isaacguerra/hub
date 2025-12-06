require "test_helper"
require "minitest/mock"

module Utils
  class BuscaPerfilWhatsappTest < ActiveSupport::TestCase
    setup do
      @original_cache_store = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      @numero = "5511999999999"
      Rails.cache.clear
    end

    teardown do
      Rails.cache = @original_cache_store
    end

    test "should fetch from API on first call and cache result" do
      # Mock the private method performing the API call
      # We can't easily stub private methods with minitest/mock on the module directly without some metaprogramming or changing visibility
      # So we will mock the cache behavior instead to ensure it's being used,
      # OR we can mock Net::HTTP to see if it's called once or twice.

      # Let's mock Net::HTTP
      response_mock = Minitest::Mock.new
      response_mock.expect :is_a?, true, [ Net::HTTPSuccess ]
      response_mock.expect :body, { id: @numero, name: "Test User", picture: "http://pic.url" }.to_json

      http_mock = Minitest::Mock.new
      http_mock.expect :use_ssl=, true, [ true ]
      http_mock.expect :request, response_mock, [ Net::HTTP::Post ]

      # We need to stub Net::HTTP.new to return our http_mock
      Net::HTTP.stub :new, http_mock do
        # First call
        result1 = Utils::BuscaPerfilWhatsapp.buscar(@numero)
        assert_equal "Test User", result1[:name]

        # Second call - should be cached
        # If caching works, it shouldn't try to make another HTTP request.
        # However, since we are stubbing Net::HTTP.new, if it calls it again, it will use the mock.
        # To verify caching, we can check if the mock expectations are met exactly once if we set them for one call.
        # But Minitest::Mock isn't strict about "at most once" unless we define it.

        # Better approach: Check Rails.cache
        assert Rails.cache.exist?("whatsapp_profile:#{@numero}")

        # Verify the cached value matches
        cached_result = Rails.cache.read("whatsapp_profile:#{@numero}")
        assert_equal result1, cached_result
      end
    end

    test "should return nil if API fails and not cache nil (or cache it depending on implementation)" do
      # In our implementation we cache the result of the block. If the block returns nil, Rails.cache.fetch might cache nil depending on config,
      # but usually we want to avoid caching transient errors.
      # The current implementation caches whatever `realizar_busca_na_api` returns.
      # If `realizar_busca_na_api` returns nil (on error), it caches nil.

      response_mock = Minitest::Mock.new
      response_mock.expect :is_a?, false, [ Net::HTTPSuccess ]
      response_mock.expect :code, "500"
      response_mock.expect :body, "Error"

      http_mock = Minitest::Mock.new
      http_mock.expect :use_ssl=, true, [ true ]
      http_mock.expect :request, response_mock, [ Net::HTTP::Post ]

      Net::HTTP.stub :new, http_mock do
        result = Utils::BuscaPerfilWhatsapp.buscar(@numero)
        assert_nil result

        # Verify if nil was cached
        # Rails.cache.fetch stores nil if the block returns nil.
        assert Rails.cache.exist?("whatsapp_profile:#{@numero}")
      end
    end
  end
end
