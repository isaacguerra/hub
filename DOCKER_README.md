# Guia de Build e Execução com Docker

Este guia utiliza o `Dockerfile` oficial do projeto como referência.

## Opção 1: Docker Compose (Recomendado)

Esta opção sobe a aplicação E o banco de dados automaticamente.

1. **Construir e Iniciar:**
   ```bash
   docker compose up --build
   ```
   Acesse em: `http://localhost:3000`

## Opção 2: Manual (Baseado no Dockerfile)

Se você preferir rodar os comandos manualmente conforme descrito no cabeçalho do `Dockerfile`.

1. **Construir a Imagem:**
   ```bash
   ./bin/docker-build
   # Ou: docker build -t appivone .
   ```

2. **Rodar o Container:**
   ```bash
   ./bin/docker-run
   # Ou: docker run -d -p 3000:80 -e RAILS_MASTER_KEY=$(cat config/master.key) --name appivone appivone
   ```

   **Atenção:** No modo manual, o container precisa de acesso a um banco de dados PostgreSQL.
   Você deve fornecer a variável de ambiente `DATABASE_URL` ou garantir que o `config/database.yml` aponte para um banco acessível (use `DB_HOST`).
