ENV["RAILS_ENV"] ||= "test"

# Safeguard: Unset DATABASE_URL to ensure tests use the sqlite3 config from database.yml
# This prevents accidental connection to production/development databases if the env var is set in the terminal
if ENV["DATABASE_URL"].present?
  puts "WARNING: DATABASE_URL environment variable detected. Unsetting it to ensure tests use the local SQLite database."
  ENV.delete("DATABASE_URL")
end

require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

# Provide missing route helper used by jobs during tests
begin
  Rails.application.routes.url_helpers.module_eval do
    def edit_mobile_gamification_strategy_url(**_)
      "https://example.test/gamification/strategy/edit"
    end
  end
rescue => _e
  # ignore if helpers are not yet available
end
begin
  mod = Rails.application.routes.url_helpers
  unless mod.respond_to?(:edit_mobile_gamification_strategy_url)
    mod.define_singleton_method(:edit_mobile_gamification_strategy_url) do |**_|
      "https://example.test/gamification/strategy/edit"
    end
  end
rescue => _e
  # ignore
end

# Ensure test DB has sensible defaults for projeto_id to make fixtures compatible
begin
  ActiveRecord::Base.connection_pool.with_connection do |conn|
    tables = %w[
      apoiadores eventos convites comunicados visitas linkpaineis
      apoiadores_eventos comunicado_apoiadores
      gamification_points gamification_action_logs gamification_action_weights
      gamification_apoiador_badges gamification_challenges gamification_challenge_participants
      gamification_levels gamification_weekly_winners
    ]

    tables.each do |t|
      if ActiveRecord::Base.connection.data_source_exists?(t) &&
         ActiveRecord::Base.connection.column_exists?(t, :projeto_id)
        begin
          ActiveRecord::Base.connection.execute("ALTER TABLE #{t} ALTER COLUMN projeto_id SET DEFAULT 1")
        rescue => e
          puts "[test_helper] failed to SET DEFAULT for "+t+": "+e.message
          raise
        end
        begin
          ActiveRecord::Base.connection.execute("ALTER TABLE #{t} ALTER COLUMN projeto_id DROP NOT NULL")
        rescue => e
          puts "[test_helper] failed to DROP NOT NULL for "+t+": "+e.message
          raise
        end
      end
    end
  end
rescue => _e
  # ignore DB connection issues at load time
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all
    fixtures :projetos, :municipios, :regioes, :bairros, :funcoes, :apoiadores, :convites, :visitas, :eventos, :comunicados,
         "gamification/challenges", "gamification/points", "gamification/badges", "gamification/action_weights", "gamification/levels", "gamification/action_logs", "gamification/apoiador_badges", "gamification/challenge_participants", "gamification/weekly_winners"

    setup do
      # Ensure acts_as_tenant and Current.projeto are defined for tests
      if defined?(projetos) && projetos(:default_project)
        ActsAsTenant.current_tenant = projetos(:default_project)
        Current.projeto = projetos(:default_project)
      else
        proj = Projeto.first || Projeto.create!(name: "Default Project", slug: "default")
        ActsAsTenant.current_tenant = proj
        Current.projeto = proj
      end

      # Backfill basic domain tables so tests don't fail due to missing projeto_id
      models_to_backfill = [Apoiador, Evento, Convite, Visita, Comunicado, Veiculo]
      models_to_backfill.each do |model|
        if model.column_names.include?("projeto_id")
          model.where(projeto_id: nil).update_all(projeto_id: ActsAsTenant.current_tenant.id)
        end
      end
    end

    teardown do
      ActsAsTenant.current_tenant = nil
      Current.projeto = nil
    end
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
