module ProjectScoped
  extend ActiveSupport::Concern

  included do
    scope :for_projeto, ->(projeto) { projeto ? where(projeto_id: projeto.id) : all }
  end
end
