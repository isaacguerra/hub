# Mapeamento Controllers ↔ Views (referência para refatoração)

Este arquivo é um ponto de consulta rápido para a refatoração de controllers e views
com objetivo de manter views separadas para `web` e `mobile` e unificar controllers
onde apropriado.

---

## Estrutura geral encontrada

- Controllers web (raiz): `ApoiadoresController`, `EventosController`, `ConvitesController`, `MunicipiosController`, `RegioesController`, `BairrosController`, `ComunicadosController`, `VisitasController`, `FuncoesController`, `SessionsController`, `HomeController`, etc.
- Controllers mobile: arquivos sob `app/controllers/mobile/` (ex.: `mobile/home_controller.rb`, `mobile/sessions_controller.rb`), views em `app/views/mobile/...`.
- API controllers: `app/controllers/api/...` (ex.: `Api::Mobile::AuthsController`, `Api::Chatbot::WebhookController`, `Api::Chatbot::ContactMessage`).
- Gamification: `app/controllers/gamification/*` e views `app/views/web/gamification` e `app/views/mobile/gamification`.

## Rotas relevantes (resumo)

- `POST /api/mobile/auth/login` -> `Api::Mobile::AuthsController#login`
- `POST /api/chatbot/webhook` -> `Api::Chatbot::WebhookController#receive`
- `GET /m/:codigo` -> `mobile/sessions#create` (magic link)
- `GET /mobile` -> `mobile/home#index`
- REST web: `resources :eventos, :visitas, :comunicados, :convites, :apoiadores, :funcoes, :regioes, :municipios, :bairros`
- Gamification admin: `namespace :gamification` -> `Gamification::ChallengesController`, `Gamification::ConfigurationsController`

## Views encontradas (padrões)

- Mobile views: `app/views/mobile/...` — muitas controllers têm templates mobile (index/show/new/edit/_form)
- Web views: `app/views/web/...` — templates e jbuilder para JSON (ex.: `web/eventos`, `web/apoiadores`, `web/comunicados`)
- Shared: `app/views/shared/*`, layouts em `app/views/layouts/mobile.html.erb`, `application.html.erb`, `auth.html.erb`.

## Problemas e pontos a corrigir (prioridade)

1. `params.expect(...)`: há múltiplos controllers usando `params.expect` (ex.: `EventosController#set_evento`, `ApoiadoresController`, `RegioesController` etc). Esse método não é Rails — substituir por `params[:id]` para IDs ou `params.require(...).permit(...)` para strong params.

2. Autenticação/API: `ApplicationController` faz `authenticate_apoiador!` que redireciona para `login_path` — para controllers API precisamos de comportamento diferente (retornar JSON 401). Recomenda-se criar `Api::BaseController` e alterar `Api::*` para herdarem dele.

3. Scoping por projeto: alguns controllers fazem `Model.all` (ex.: `Evento.all`) — confirmar que `acts_as_tenant` ou `ProjectScoped` é aplicado nos models/queries para garantir isolamento por `projeto`.

4. Layouts e seleção de view: manter views separadas em `app/views/web` e `app/views/mobile`. Garantir que controllers/single actions renderizem templates corretos (p.ex. `render 'mobile/eventos/index'` ou `render :index` com `layout` adequado). O helper `mobile_device?` está disponível.

5. Callbacks assíncronos: preferir `after_commit` para enviar notificações/mensageria, evitando dispatchs quando a transação falha.

6. Prevenção de ciclos em hierarquia: ao refatorar métodos que percorrem rede de apoiadores, garantir checagem de ciclos.

## Sugestão de passos para refatoração (por controller)

- Passo 1: substituir `params.expect` por `params[:id]` ou `params.require(...).permit(...)`.
- Passo 2: garantir scoping: usar `scope = Model.for_projeto` ou `Model.where(projeto: Current.projeto)` quando necessário.
- Passo 3: separar respostas JSON/API: mover lógica de API para `Api::BaseController`.
- Passo 4: verificar views: quando controller atende web + mobile, confirmar existência de `app/views/web/...` e `app/views/mobile/...` e escolher via `mobile_device?` ou rotas dedicadas em `mobile/*`.
- Passo 5: atualizar testes de controller e integration para cobrir ambos os formatos.

## Arquivos com ocorrências de `params.expect` (pontos iniciais)

- `app/controllers/eventos_controller.rb` (set_evento, evento_params)
- `app/controllers/regioes_controller.rb`
- `app/controllers/convites_controller.rb`
- `app/controllers/municipios_controller.rb`
- `app/controllers/funcoes_controller.rb`
- `app/controllers/bairros_controller.rb`
- `app/controllers/comunicados_controller.rb`
- `app/controllers/apoiadores_controller.rb`

(Use `git grep "params.expect"` para listar exato e localizar linhas a corrigir.)

## Notas operacionais

- Crie `Api::BaseController < ActionController::API` (ou derivado) e implemente `authenticate_api_user!` que retorna JSON com 401/403.
- Para controllers que devem continuar servindo HTML, mantenha herança de `ApplicationController`.
- Para unificar lógica entre web/mobile, prefira refatorar _helpers_ e partials reutilizáveis, não misturar render paths dentro das ações.

---

Arquivo gerado automaticamente pelo assistente para servir como referência durante a refatoração.
