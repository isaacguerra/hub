# Mensageria - Sistema de Notificações

Sistema modular de mensageria para envio de notificações via WhatsApp através do Redis e N8N.

## Estrutura

```
lib/mensageria/
├── mensageria.rb              # Módulo principal com autoload
├── redis_client.rb            # Cliente Redis (singleton)
├── logger.rb                  # Logger de mensagens para Redis
├── helpers.rb                 # Helpers (formatação de telefone)
├── lideranca.rb               # Hierarquia de liderança
├── busca_imagem_whatsapp.rb   # Busca imagem de perfil via N8N
├── mensagens/
│   ├── convites.rb            # Templates de mensagens de convites
│   ├── visitas.rb             # Templates de mensagens de visitas
│   └── estatisticas.rb        # Geração de estatísticas
└── notificacoes/
    ├── convites.rb            # Notificações de convites
    └── visitas.rb             # Notificações de visitas
```

## Uso

### Notificar Novo Convite

```ruby
convite = Convite.find(1)
Mensageria::Notificacoes::Convites.notificar_novo_convite(convite)
```

### Notificar Convite Aceito

```ruby
apoiador = Apoiador.find(1)
Mensageria::Notificacoes::Convites.notificar_convite_aceito(apoiador)
```

### Notificar Nova Visita

```ruby
visita = Visita.find(1)
Mensageria::Notificacoes::Visitas.notificar_nova_visita(visita)
```

### Notificar Visita Realizada

```ruby
visita = Visita.find(1)
Mensageria::Notificacoes::Visitas.notificar_visita_realizada(visita)
```

### Uso Direto dos Módulos

```ruby
# Buscar hierarquia de liderança
apoiador = Apoiador.find(1)
lideres = Mensageria::Lideranca.buscar_hierarquia(apoiador)

# Notificar toda a liderança
Mensageria::Lideranca.notificar(
  apoiador: apoiador,
  mensagem: "Mensagem personalizada",
  image_whatsapp: "https://exemplo.com/imagem.jpg"
)

# Gerar estatísticas
estatisticas_apoiadores = Mensageria::Mensagens::Estatisticas.gerar_apoiadores
estatisticas_convites = Mensageria::Mensagens::Estatisticas.gerar_convites
estatisticas_visitas = Mensageria::Mensagens::Estatisticas.gerar_visitas

# Formatar número de telefone
telefone = Mensageria::Helpers.format_phone_number("(96) 99999-9999")
# => "5596999999999"

# Buscar imagem do WhatsApp
imagem_url = Utils::BuscaImagemWhatsapp.buscar("5596999999999")
```

## Variáveis de Ambiente

```bash
# Redis
REDIS_URL=redis://localhost:6379/1

# N8N Webhooks
N8N_WEBHOOK_BUSCA_IMAGEM_WHATSAPP=https://n8n.exemplo.com/webhook/busca-imagem

# URLs
BASE_URL=https://app.exemplo.com
IMAGEM_CONVITE=https://app.exemplo.com/images/convite.jpg
```

## Hierarquia de Liderança

O sistema busca automaticamente a hierarquia completa de liderança:

1. **Líder Direto** - Líder imediato do apoiador
2. **Coordenador Municipal** (funcaoId: 4) - Coordenador do município
3. **Coordenador Regional** (funcaoId: 3) - Coordenador da região
4. **Coordenadores Gerais** (funcaoId: 2) - Todos os coordenadores gerais
5. **Candidatos** (funcaoId: 1) - Todos os candidatos

## Fluxo de Mensagens

1. A aplicação chama uma função de notificação
2. O sistema gera a mensagem formatada
3. A mensagem é publicada no Redis (canal `mensageria_logs`)
4. O N8N consome a mensagem do Redis
5. O N8N envia via WhatsApp

## Conversão do TypeScript

Este módulo foi convertido da estrutura TypeScript original mantendo:
- ✅ Mesma organização modular
- ✅ Mesmas funcionalidades
- ✅ Mesmos templates de mensagens
- ✅ Padrões Ruby (snake_case, convenções Rails)
- ✅ Tratamento de erros com logs
