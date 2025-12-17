# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_17_000200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "apoiadores", force: :cascade do |t|
    t.bigint "bairro_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "facebook"
    t.bigint "funcao_id", null: false
    t.string "instagram"
    t.bigint "lider_id"
    t.bigint "municipio_id", null: false
    t.string "name", null: false
    t.bigint "projeto_id", null: false
    t.bigint "regiao_id", null: false
    t.string "secao_eleitoral"
    t.integer "subordinados_count", default: 0, null: false
    t.string "tiktok"
    t.string "titulo_eleitoral"
    t.datetime "updated_at", null: false
    t.string "verification_code"
    t.datetime "verification_code_expires_at"
    t.string "whatsapp", null: false
    t.string "zona_eleitoral"
    t.index ["bairro_id", "funcao_id"], name: "index_apoiadores_on_bairro_id_and_funcao_id"
    t.index ["bairro_id"], name: "index_apoiadores_on_bairro_id"
    t.index ["email"], name: "index_apoiadores_on_email", unique: true
    t.index ["funcao_id"], name: "index_apoiadores_on_funcao_id"
    t.index ["lider_id"], name: "index_apoiadores_on_lider_id"
    t.index ["municipio_id", "funcao_id"], name: "index_apoiadores_on_municipio_id_and_funcao_id"
    t.index ["municipio_id"], name: "index_apoiadores_on_municipio_id"
    t.index ["projeto_id"], name: "index_apoiadores_on_projeto_id"
    t.index ["regiao_id", "funcao_id"], name: "index_apoiadores_on_regiao_id_and_funcao_id"
    t.index ["regiao_id"], name: "index_apoiadores_on_regiao_id"
    t.index ["whatsapp"], name: "index_apoiadores_on_whatsapp", unique: true
  end

  create_table "apoiadores_eventos", id: false, force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "assigned_at", null: false
    t.string "assigned_by", null: false
    t.bigint "evento_id", null: false
    t.integer "projeto_id", null: false
    t.index ["apoiador_id", "evento_id"], name: "index_apoiadores_eventos_on_apoiador_id_and_evento_id", unique: true
    t.index ["apoiador_id"], name: "index_apoiadores_eventos_on_apoiador_id"
    t.index ["evento_id"], name: "index_apoiadores_eventos_on_evento_id"
    t.index ["projeto_id"], name: "index_apoiadores_eventos_on_projeto_id"
  end

  create_table "bairros", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "regiao_id", null: false
    t.datetime "updated_at", null: false
    t.index ["regiao_id"], name: "index_bairros_on_regiao_id"
  end

  create_table "comunicado_apoiadores", id: false, force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.bigint "comunicado_id", null: false
    t.datetime "created_at", null: false
    t.boolean "engajado", default: false, null: false
    t.integer "projeto_id", null: false
    t.boolean "recebido", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["apoiador_id"], name: "index_comunicado_apoiadores_on_apoiador_id"
    t.index ["comunicado_id", "apoiador_id"], name: "index_comunicado_apoiadores_on_comunicado_id_and_apoiador_id", unique: true
    t.index ["comunicado_id"], name: "index_comunicado_apoiadores_on_comunicado_id"
    t.index ["projeto_id"], name: "index_comunicado_apoiadores_on_projeto_id"
  end

  create_table "comunicados", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "data", null: false
    t.string "imagem"
    t.bigint "lider_id", null: false
    t.string "link_facebook"
    t.string "link_instagram"
    t.string "link_tiktok"
    t.string "link_whatsapp"
    t.text "mensagem", null: false
    t.bigint "projeto_id", null: false
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.index ["lider_id"], name: "index_comunicados_on_lider_id"
    t.index ["projeto_id"], name: "index_comunicados_on_projeto_id"
  end

  create_table "convites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enviado_por_id", null: false
    t.string "nome", null: false
    t.bigint "projeto_id", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.string "whatsapp", null: false
    t.index ["enviado_por_id"], name: "index_convites_on_enviado_por_id"
    t.index ["projeto_id"], name: "index_convites_on_projeto_id"
  end

  create_table "eventos", force: :cascade do |t|
    t.bigint "coordenador_id", null: false
    t.datetime "created_at", null: false
    t.datetime "data", null: false
    t.text "descricao"
    t.bigint "filtro_bairro_id"
    t.bigint "filtro_funcao_id"
    t.bigint "filtro_municipio_id"
    t.bigint "filtro_regiao_id"
    t.string "imagem"
    t.string "link_facebook"
    t.string "link_instagram"
    t.string "link_tiktok"
    t.string "link_whatsapp"
    t.string "local"
    t.bigint "projeto_id", null: false
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.index ["coordenador_id"], name: "index_eventos_on_coordenador_id"
    t.index ["filtro_bairro_id"], name: "index_eventos_on_filtro_bairro_id"
    t.index ["filtro_funcao_id"], name: "index_eventos_on_filtro_funcao_id"
    t.index ["filtro_municipio_id"], name: "index_eventos_on_filtro_municipio_id"
    t.index ["filtro_regiao_id"], name: "index_eventos_on_filtro_regiao_id"
    t.index ["projeto_id"], name: "index_eventos_on_projeto_id"
  end

  create_table "funcoes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_funcoes_on_name", unique: true
  end

  create_table "gamification_action_logs", force: :cascade do |t|
    t.string "action_type", null: false
    t.bigint "apoiador_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.integer "points_awarded", default: 0
    t.bigint "projeto_id", null: false
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["apoiador_id", "action_type"], name: "index_gamification_action_logs_on_apoiador_id_and_action_type"
    t.index ["apoiador_id"], name: "index_gamification_action_logs_on_apoiador_id"
    t.index ["created_at"], name: "index_gamification_action_logs_on_created_at"
    t.index ["projeto_id"], name: "index_gamification_action_logs_on_projeto_id"
    t.index ["resource_type", "resource_id"], name: "index_gamification_action_logs_on_resource"
  end

  create_table "gamification_action_weights", force: :cascade do |t|
    t.string "action_type"
    t.datetime "created_at", null: false
    t.string "description"
    t.integer "points"
    t.bigint "projeto_id", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_gamification_action_weights_on_action_type"
    t.index ["projeto_id"], name: "index_gamification_action_weights_on_projeto_id"
  end

  create_table "gamification_apoiador_badges", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "awarded_at"
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.bigint "projeto_id", null: false
    t.datetime "updated_at", null: false
    t.index ["apoiador_id", "badge_id"], name: "index_gamification_apoiador_badges_on_apoiador_id_and_badge_id", unique: true
    t.index ["apoiador_id"], name: "index_gamification_apoiador_badges_on_apoiador_id"
    t.index ["badge_id"], name: "index_gamification_apoiador_badges_on_badge_id"
    t.index ["projeto_id"], name: "index_gamification_apoiador_badges_on_projeto_id"
  end

  create_table "gamification_badges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "criteria", default: {}
    t.text "description"
    t.string "image_url"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_gamification_badges_on_key", unique: true
  end

  create_table "gamification_challenge_participants", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.integer "points", default: 0
    t.jsonb "progress", default: {}
    t.bigint "projeto_id", null: false
    t.datetime "updated_at", null: false
    t.index ["apoiador_id"], name: "index_gamification_challenge_participants_on_apoiador_id"
    t.index ["challenge_id", "apoiador_id"], name: "idx_on_challenge_id_apoiador_id_6dd107188a", unique: true
    t.index ["challenge_id"], name: "index_gamification_challenge_participants_on_challenge_id"
    t.index ["projeto_id"], name: "index_gamification_challenge_participants_on_projeto_id"
  end

  create_table "gamification_challenges", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at"
    t.bigint "projeto_id", null: false
    t.string "reward"
    t.jsonb "rules"
    t.datetime "starts_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "winner_id"
    t.index ["projeto_id"], name: "index_gamification_challenges_on_projeto_id"
    t.index ["winner_id"], name: "index_gamification_challenges_on_winner_id"
  end

  create_table "gamification_levels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "experience_threshold"
    t.integer "level"
    t.bigint "projeto_id", null: false
    t.datetime "updated_at", null: false
    t.index ["level"], name: "index_gamification_levels_on_level"
    t.index ["projeto_id"], name: "index_gamification_levels_on_projeto_id"
  end

  create_table "gamification_points", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "created_at", null: false
    t.integer "level", default: 1, null: false
    t.integer "points", default: 0, null: false
    t.bigint "projeto_id", null: false
    t.datetime "updated_at", null: false
    t.index ["apoiador_id"], name: "index_gamification_points_on_apoiador_id", unique: true
    t.index ["points"], name: "index_gamification_points_on_points"
    t.index ["projeto_id"], name: "index_gamification_points_on_projeto_id"
  end

  create_table "gamification_weekly_winners", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "created_at", null: false
    t.integer "points_total"
    t.bigint "projeto_id", null: false
    t.datetime "updated_at", null: false
    t.date "week_end_date"
    t.date "week_start_date"
    t.text "winning_strategy"
    t.index ["apoiador_id"], name: "index_gamification_weekly_winners_on_apoiador_id"
    t.index ["projeto_id"], name: "index_gamification_weekly_winners_on_projeto_id"
  end

  create_table "linkpaineis", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "created_at", null: false
    t.bigint "projeto_id", null: false
    t.string "real_ip"
    t.string "slug", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["apoiador_id"], name: "index_linkpaineis_on_apoiador_id"
    t.index ["projeto_id"], name: "index_linkpaineis_on_projeto_id"
    t.index ["slug"], name: "index_linkpaineis_on_slug", unique: true
  end

  create_table "municipios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projetos", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "candidato"
    t.string "candidato_whatsapp"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.string "name", null: false
    t.jsonb "settings", default: {}
    t.string "site"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_projetos_on_slug", unique: true
  end

  create_table "regioes", force: :cascade do |t|
    t.bigint "coordenador_id"
    t.datetime "created_at", null: false
    t.bigint "municipio_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["coordenador_id"], name: "index_regioes_on_coordenador_id"
    t.index ["municipio_id"], name: "index_regioes_on_municipio_id"
  end

  create_table "veiculos", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "created_at", null: false
    t.boolean "disponivel", default: true, null: false
    t.string "modelo", null: false
    t.string "placa", null: false
    t.bigint "projeto_id"
    t.string "tipo", null: false
    t.datetime "updated_at", null: false
    t.index ["apoiador_id"], name: "index_veiculos_on_apoiador_id"
    t.index ["projeto_id"], name: "index_veiculos_on_projeto_id"
  end

  create_table "visitas", force: :cascade do |t|
    t.bigint "apoiador_id", null: false
    t.datetime "created_at", null: false
    t.bigint "lider_id", null: false
    t.bigint "projeto_id", null: false
    t.text "relato"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["apoiador_id"], name: "index_visitas_on_apoiador_id"
    t.index ["lider_id"], name: "index_visitas_on_lider_id"
    t.index ["projeto_id"], name: "index_visitas_on_projeto_id"
  end

  add_foreign_key "apoiadores", "apoiadores", column: "lider_id"
  add_foreign_key "apoiadores", "bairros"
  add_foreign_key "apoiadores", "funcoes"
  add_foreign_key "apoiadores", "municipios"
  add_foreign_key "apoiadores", "projetos"
  add_foreign_key "apoiadores", "regioes"
  add_foreign_key "apoiadores_eventos", "apoiadores"
  add_foreign_key "apoiadores_eventos", "eventos"
  add_foreign_key "apoiadores_eventos", "projetos"
  add_foreign_key "bairros", "regioes"
  add_foreign_key "comunicado_apoiadores", "apoiadores"
  add_foreign_key "comunicado_apoiadores", "comunicados"
  add_foreign_key "comunicado_apoiadores", "projetos"
  add_foreign_key "comunicados", "apoiadores", column: "lider_id"
  add_foreign_key "comunicados", "projetos"
  add_foreign_key "convites", "apoiadores", column: "enviado_por_id"
  add_foreign_key "convites", "projetos"
  add_foreign_key "eventos", "apoiadores", column: "coordenador_id"
  add_foreign_key "eventos", "bairros", column: "filtro_bairro_id"
  add_foreign_key "eventos", "funcoes", column: "filtro_funcao_id"
  add_foreign_key "eventos", "municipios", column: "filtro_municipio_id"
  add_foreign_key "eventos", "projetos"
  add_foreign_key "eventos", "regioes", column: "filtro_regiao_id"
  add_foreign_key "gamification_action_logs", "apoiadores"
  add_foreign_key "gamification_action_logs", "projetos"
  add_foreign_key "gamification_action_weights", "projetos"
  add_foreign_key "gamification_apoiador_badges", "apoiadores"
  add_foreign_key "gamification_apoiador_badges", "gamification_badges", column: "badge_id"
  add_foreign_key "gamification_apoiador_badges", "projetos"
  add_foreign_key "gamification_challenge_participants", "apoiadores"
  add_foreign_key "gamification_challenge_participants", "gamification_challenges", column: "challenge_id"
  add_foreign_key "gamification_challenge_participants", "projetos"
  add_foreign_key "gamification_challenges", "apoiadores", column: "winner_id"
  add_foreign_key "gamification_challenges", "projetos"
  add_foreign_key "gamification_levels", "projetos"
  add_foreign_key "gamification_points", "apoiadores"
  add_foreign_key "gamification_points", "projetos"
  add_foreign_key "gamification_weekly_winners", "apoiadores"
  add_foreign_key "gamification_weekly_winners", "projetos"
  add_foreign_key "linkpaineis", "apoiadores"
  add_foreign_key "linkpaineis", "projetos"
  add_foreign_key "regioes", "apoiadores", column: "coordenador_id"
  add_foreign_key "regioes", "municipios"
  add_foreign_key "veiculos", "apoiadores"
  add_foreign_key "visitas", "apoiadores"
  add_foreign_key "visitas", "apoiadores", column: "lider_id"
  add_foreign_key "visitas", "projetos"
end
