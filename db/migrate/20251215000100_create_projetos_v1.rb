class CreateProjetosV1 < ActiveRecord::Migration[8.1]
  def change
    create_table :projetos do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :candidate_name
      t.string :candidate_contact
      t.text :description
      t.boolean :active, default: true, null: false
      t.string :timezone
      t.string :locale, default: 'pt-BR'
      t.jsonb :settings, default: {}
      t.string :evolution_instance_id
      t.string :evolution_whatsapp_number
      t.string :provisioning_status, default: 'pending'
      t.text :provisioning_error
      t.bigint :created_by_id

      t.timestamps
    end

    add_index :projetos, :slug, unique: true
    add_index :projetos, :evolution_instance_id
  end
end
