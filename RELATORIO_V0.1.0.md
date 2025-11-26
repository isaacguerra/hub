# Relatório de Funcionalidades - Versão 0.1.0

## Visão Geral
A versão 0.1.0 do Appivone estabelece a fundação do sistema de gestão de campanha eleitoral, focando na gestão de apoiadores, hierarquia de liderança e funcionalidades de visitas, tanto para Web quanto para Mobile.

## Funcionalidades Implementadas

### 1. Autenticação e Segurança
- **Login via WhatsApp**: Sistema de autenticação sem senha ("passwordless"), utilizando o número do WhatsApp como identificador.
- **Verificação em Duas Etapas**: Envio de código de 6 dígitos via integração de mensageria para validar o acesso.
- **Gestão de Sessão**: Controle de sessão seguro com suporte a redirecionamento diferenciado para dispositivos Móveis e Web.
- **Controle de Acesso (RBAC)**: Permissões baseadas na função do apoiador (Candidato, Coordenadores, Líder, Apoiador).

### 2. Gestão de Apoiadores (CRM Político)
- **Hierarquia Completa**:
  - Candidato
  - Coordenador Geral
  - Coordenador de Município
  - Coordenador de Região
  - Coordenador de Bairro
  - Líder
  - Apoiador
- **Promoção Automática**: Apoiadores são promovidos automaticamente a Líderes ao atingirem 25 subordinados diretos.
- **Escopo de Visualização**: Usuários veem apenas os dados pertinentes à sua jurisdição (ex: Coordenador de Bairro vê apenas apoiadores do seu bairro).
- **Cadastro Completo**: Dados pessoais, endereço, função e vínculo com líder superior.

### 3. Gestão de Território
- **Estrutura Aninhada**:
  - Municípios
  - Regiões (vinculadas a Municípios)
  - Bairros (vinculados a Regiões)
- **Rotas Aninhadas**: URLs semânticas para navegação territorial (ex: `/municipios/1/regioes/2/bairros`).

### 4. Módulo de Visitas
- **Interface Web**: CRUD completo para gestão de visitas, permitindo agendamento e registro de feedback.
- **Interface Mobile**: Suporte a API para aplicativos móveis.
- **Status de Visita**: Fluxo de trabalho com estados (Pendente, Realizada, Cancelada).
- **Geolocalização**: Suporte para registro de latitude e longitude.

### 5. Mensageria e Notificações
- **Arquitetura Assíncrona**: Integração via Redis para processamento de mensagens em background.
- **Triggers Implementados**:
  - `Autenticacao`: Envio de códigos de login.
  - `Apoiadores`: Notificação de novos cadastros e mudanças de função.
  - `Convites`: Notificação de aceite de convites.
  - `Eventos`: Notificações de agenda (preparado).

## Validação Técnica
- **Testes Automatizados**: Suíte de testes de integração e controladores refatorada para cobrir fluxos críticos.
- **Correções de Bugs**:
  - Resolução de problemas de rotas aninhadas nos testes de Regiões e Bairros.
  - Normalização de números de WhatsApp para garantir consistência.
  - Ajustes na persistência de sessão em ambiente de teste.

## Próximos Passos (Roadmap)
- Implementação de Dashboards analíticos.
- Expansão do módulo de Eventos.
- Refinamento da API Mobile.

---
**Data**: 26 de Novembro de 2025
**Versão**: 0.1.0
