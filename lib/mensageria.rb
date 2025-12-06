# frozen_string_literal: true

# Módulo principal da Mensageria
# Exporta todos os submódulos para facilitar o uso
module Mensageria
  # Autoload dos módulos
  autoload :Logger, "mensageria/logger"
  autoload :Helpers, "mensageria/helpers"
  autoload :Lideranca, "mensageria/lideranca"

  module Mensagens
    autoload :Convites, "mensageria/mensagens/convites"
    autoload :Visitas, "mensageria/mensagens/visitas"
    autoload :Estatisticas, "mensageria/mensagens/estatisticas"
    autoload :Comunicados, "mensageria/mensagens/comunicados"
  end

  module Notificacoes
    autoload :Convites, "mensageria/notificacoes/convites"
    autoload :Visitas, "mensageria/notificacoes/visitas"
    autoload :Comunicados, "mensageria/notificacoes/comunicados"
    autoload :Autenticacao, "mensageria/notificacoes/autenticacao"
    autoload :Apoiadores, "mensageria/notificacoes/apoiadores"
    autoload :Eventos, "mensageria/notificacoes/eventos"
  end
end
