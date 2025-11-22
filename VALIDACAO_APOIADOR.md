# Validação do Modelo Apoiador

## ✅ Requisitos dos Comentários vs Implementação

### 1. **Funções e Hierarquia** ✅
**Comentário:** "Um Apoiador pode ter uma função específica, como Candidato, Coordenador Geral, Coordenador de Município, Coordenador de Região, Coordenador de Bairro, Lider ou simplesmente Apoiador"

**Implementado:**
- ✅ Métodos de verificação: `candidato?`, `coordenador_geral?`, `coordenador_municipal?`, `coordenador_regional?`, `coordenador_bairro?`, `lider?`, `apoiador_base?`
- ✅ Método auxiliar: `pode_coordenar?`

---

### 2. **Promoção Automática a Líder** ✅
**Comentário:** "Um Apoiador muda de Funcao de Apoiador para Lider automaticamente apos alcancar 25 apoiadores diretamente subordinados a ele"

**Implementado:**
- ✅ `verificar_promocao_lider` (after_update)
- ✅ `atualizar_promocao_lider_superior` (after_save quando muda líder)
- ✅ Verifica automaticamente quando subordinados mudam

---

### 3. **Função para Retornar Líderes** ✅
**Comentário:** "A partir do id do deve haver uma funcao que retorne seus lideres, que sao todos: Candidatos, Coordenadores Gerais, Coordenadores de Municipio que ele percence, Coordenadores de Regiao que ele pertence, Coordenadores de Bairro que ele pertence e Lidere que ele pertence"

**Implementado:**
- ✅ `hierarquia_lideranca` - retorna array com todos os líderes
- ✅ `lideres` - alias para hierarquia_lideranca
- ✅ Usa `Mensageria::Lideranca.buscar_hierarquia(self)`
- ✅ Retorna: Líder direto, Coord. Municipal, Coord. Regional, Coords. Gerais, Candidatos

---

### 4. **Função para Retornar Subordinados** ✅
**Comentário:** "E tambem uma funcao que retorne todos os apoiadores que ele lidera, sejam eles diretamente ou indiretamente"

**Implementado:**
- ✅ `todos_subordinados(incluir_indiretos: true)` - retorna array com subordinados
- ✅ `total_subordinados_diretos` - conta apenas diretos
- ✅ Algoritmo recursivo usando fila para subordinados indiretos

---

### 5. **Mensageria: Criar Novo Apoiador** ✅
**Comentário:** "Ao criar um novo Apoiador, devemos gravar uma mensagem no channel mensageria no redis com os dados do novo Apoiador"

**Implementado:**
- ✅ `after_create :notificar_novo_apoiador`
- ✅ Notifica sempre (exceto se for via convite)
- ✅ Notificação específica para convites: `notificar_convite_aceito`

---

### 6. **Mensageria: Mudança de Função** ✅
**Comentário:** "Ao Mudar a funcao de um Apoiador devemos gravar uma mensagem no channel mensageria no redis com os dados do Apoiador e sua nova funcao. e devemos gravar uma mensagem no channel mensageria informando os lideres do Apoiador que sua rede de apoiadores mudou"

**Implementado:**
- ✅ `after_update :notificar_mudanca_funcao, if: :saved_change_to_funcao_id?`
- ✅ Notifica toda a hierarquia via `Mensageria::Lideranca.notificar`
- ✅ Inclui função anterior e nova função na mensagem

---

## 📋 Callbacks Implementados

```ruby
after_create :notificar_novo_apoiador
after_create :notificar_convite_aceito, if: :criado_por_convite?
after_update :verificar_promocao_lider
after_update :notificar_mudanca_funcao, if: :saved_change_to_funcao_id?
after_save :atualizar_promocao_lider_superior, if: :saved_change_to_lider_id?
```

---

## 🔧 Métodos Públicos

### Hierarquia e Liderança
- `hierarquia_lideranca` / `lideres` - Retorna todos os líderes
- `todos_subordinados(incluir_indiretos: true)` - Retorna subordinados
- `total_subordinados_diretos` - Conta subordinados diretos

### Verificadores de Função
- `candidato?`
- `coordenador_geral?`
- `coordenador_municipal?`
- `coordenador_regional?`
- `coordenador_bairro?`
- `lider?`
- `apoiador_base?`
- `pode_coordenar?`

---

## ✅ Conclusão

**Todos os requisitos dos comentários foram implementados corretamente!**

- ✅ Hierarquia de liderança
- ✅ Subordinados diretos e indiretos
- ✅ Promoção automática a Líder (25 subordinados)
- ✅ Notificações via mensageria
- ✅ Métodos auxiliares de verificação
- ✅ Tratamento de erros em todos os callbacks
