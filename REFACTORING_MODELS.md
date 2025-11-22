# Refatoração dos Modelos - Integração com Mensageria

## Modelos Refatorados

### 1. **Convite** (`app/models/convite.rb`)

#### Callbacks Adicionados:
- `after_create :notificar_novo_convite` - Notifica quando um convite é criado
- `after_update :notificar_mudanca_status` - Notifica mudanças no status

#### Validações Adicionadas:
- Status deve ser: `pendente`, `aceito` ou `recusado`

#### Fluxo de Notificações:
1. **Novo convite criado** → Notifica o convidado e a liderança
2. **Convite aceito** → Notificação disparada no modelo Apoiador (ao criar o novo apoiador)
3. **Convite recusado** → Log no sistema (TODO: implementar notificação completa)

---

### 2. **Visita** (`app/models/visita.rb`)

#### Callbacks Adicionados:
- `after_create :notificar_nova_visita` - Notifica quando visita é agendada
- `after_update :notificar_atualizacao_visita` - Notifica mudanças no status

#### Validações Adicionadas:
- Status deve ser: `pendente`, `concluida` ou `cancelada`

#### Fluxo de Notificações:
1. **Nova visita agendada** → Notifica apoiador visitado, líder e hierarquia
2. **Visita concluída** → Notifica apoiador visitado e hierarquia com relato
3. **Visita cancelada** → Log no sistema (TODO: implementar notificação completa)

---

### 3. **Apoiador** (`app/models/apoiador.rb`)

#### Callbacks Adicionados:
- `after_create :notificar_convite_aceito` - Notifica quando criado via convite aceito
- `after_update :verificar_promocao_lider` - Verifica se deve ser promovido a Líder
- `after_update :notificar_mudanca_funcao` - Notifica mudança de função

#### Novos Métodos Públicos:

**`hierarquia_lideranca`**
```ruby
# Retorna toda a hierarquia de liderança do apoiador
apoiador.hierarquia_lideranca
# => [líder_direto, coord_municipal, coord_regional, coords_gerais, candidatos]
```

**`todos_subordinados(incluir_indiretos: true)`**
```ruby
# Retorna todos subordinados diretos e indiretos
apoiador.todos_subordinados
# => [subordinado1, subordinado2, ...]

# Apenas subordinados diretos
apoiador.todos_subordinados(incluir_indiretos: false)
```

**`total_subordinados_diretos`**
```ruby
# Conta subordinados diretos (usado para promoção automática)
apoiador.total_subordinados_diretos
# => 25
```

#### Funcionalidades Automáticas:

**Promoção Automática a Líder**
- Quando um apoiador atinge **25 subordinados diretos**
- É automaticamente promovido de "Apoiador" para "Líder"
- A hierarquia é notificada sobre a mudança

**Notificação de Convite Aceito**
- Detecta quando um apoiador é criado via convite aceito
- Notifica o novo apoiador (boas-vindas)
- Notifica o líder direto
- Notifica toda a hierarquia

**Notificação de Mudança de Função**
- Notifica toda a hierarquia quando a função muda
- Inclui função anterior e nova função

---

## Integração com Mensageria

Todos os modelos agora utilizam o sistema de mensageria automaticamente:

```ruby
# Exemplo de uso direto
Mensageria::Notificacoes::Convites.notificar_novo_convite(convite)
Mensageria::Notificacoes::Visitas.notificar_nova_visita(visita)
Mensageria::Lideranca.notificar(apoiador: apoiador, mensagem: "texto")
```

## Tratamento de Erros

Todos os callbacks têm tratamento de erros:
- Erros são logados no `Rails.logger`
- Não interrompem o fluxo principal
- Incluem ID do registro e mensagem de erro

## Próximos Passos (TODO)

1. Implementar notificação de convite recusado
2. Implementar notificação de visita cancelada
3. Ajustar IDs das funções no banco (Apoiador e Líder)
4. Adicionar testes automatizados para callbacks
5. Implementar notificações para Comunicados e Eventos
