# Mapeamento de Regras de Autorização

Este documento lista os locais identificados no código onde regras de autorização baseadas em `Funcao` (nome ou string) são utilizadas.

## 1. Modelos (Lógica de Negócio)

### `app/models/apoiador.rb`
- **Métodos Auxiliares**: `candidato?`, `coordenador_geral?`, `coordenador_municipal?`, `coordenador_regional?`, `coordenador_bairro?`, `lider?`, `apoiador_base?`.
- **Lógica de Grupo**: `pode_coordenar?` (Agrupa todos os coordenadores).
- **Callbacks**: Atribuição de IDs baseada em `Funcao.find_by(name: ...)`.

### `app/models/concerns/rede_apoiadores.rb`
- **Método `coordenadores`**: Usa `joins(:funcao).where(funcoes: { name: ... })`.
- **Método `liderados`**: Usa `case funcao&.name`.

### `app/models/comunicado.rb`
- **Validação**: `unless lider.pode_coordenar? || lider.lider?`.

### `app/models/evento.rb`
- **Validação**: `unless coordenador.pode_coordenar? || coordenador.lider?`.

## 2. Controllers (Proteção de Rotas)

### `app/controllers/eventos_controller.rb`
- `authorize_create`: Usa `pode_coordenar?` ou `lider?`.
- `authorize_manage`: Usa `candidato?`, `coordenador_geral?` ou verificação de propriedade.

### `app/controllers/regioes_controller.rb`, `municipios_controller.rb`, `bairros_controller.rb`
- `authorize_admin!`: Usa `candidato?` ou `coordenador_geral?`.

### `app/controllers/mobile/apoiadores_controller.rb`
- `authorize_manage`: Lógica similar.

### `app/controllers/convites_publicos_controller.rb`
- Busca função por string: `Funcao.find_by(name: "Apoiador")`.

## 3. Views (Exibição Condicional)

- `app/views/visitas/show.html.erb`: Botões de edição/exclusão.
- `app/views/visitas/index.html.erb`: Botões de ação.
- `app/views/mobile/eventos/show.html.erb`: Botões de ação.
- `app/views/mobile/dashboard/index.html.erb`: Exibição de painéis administrativos.

## 4. Seeds e Testes
- `db/seeds.rb`: Criação de funções por string.
- `test/fixtures/funcoes.yml`: Definição de IDs (já alinhados com o plano).
