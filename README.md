# PostgreSQL com Docker Compose

<div align="center">

![Curso de Banco de Dados](https://img.shields.io/badge/Curso%20de%20Banco%20de%20Dados-Rocketseat-0078D4?style=for-the-badge&logo=azuredevops)

<!-- ![Disciplina](https://img.shields.io/badge/Disciplina-ADS-4B8BBE?style=for-the-badge&logo=github) -->
<!-- ![Professora](https://img.shields.io/badge/Prof-Luciene%20Chagas%20de%20Oliveira-FFCA28?style=for-the-badge&logo=linkedin) -->

**Instituição:** [Rocketseat](https://www.rocketseat.com.br/)  
**Curso:** Banco de Dados

<!-- **Professor:** [Luciene Chagas de Oliveira, Ph.D](https://www.linkedin.com/in/luciene-chagas-de-oliveira-ph-d-b21b3b31/) -->

</div>

Um ambiente completo de desenvolvimento PostgreSQL usando Docker Compose com Beekeeper Studio e pgAdmin para gerenciamento de banco de dados.

## 📋 Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) instalado
- [Docker Compose](https://docs.docker.com/compose/install/) instalado
- Conhecimento básico de PostgreSQL e Docker

## Sumário

- Tutorial em Português para configuração do ambiente
  - [WSL + Ubuntu + Docker + Docker Compose + Beekeeper](/docs/WSL-Ubuntu-Docker-Setup.md)
- Tipos de Dados em PostgreSQL
  - [Visão Geral dos Tipos de Dados](./docs/data-types.md)
- Comandos SQL Essenciais
  - [Guia Prático de Comandos SQL (PostgreSQL)](./docs/sql-commands.md)

## ⚙️ Configuração de Ambiente

### 1. Configurar Variáveis de Ambiente

Antes de iniciar, você **deve** configurar as variáveis de ambiente editando o arquivo `.env`:

```bash
# Copie o exemplo e edite com seus valores
cp .env.example .env  # Se você tiver um arquivo de exemplo
# OU edite o arquivo .env existente
nano .env
```

### 2. Explicação das Variáveis de Ambiente

O arquivo `.env` contém todas as variáveis de configuração:

```properties
# Configuração do Banco PostgreSQL
POSTGRES_DB=database_course          # Nome do banco de dados a ser criado
POSTGRES_USER=postgres               # Nome de usuário do PostgreSQL
POSTGRES_PASSWORD=postgres123        # Senha do PostgreSQL (ALTERE EM PRODUÇÃO!)

# Configuração da Interface Web pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@admin.com    # Email de login do pgAdmin
PGADMIN_DEFAULT_PASSWORD=admin123        # Senha de login do pgAdmin (ALTERE EM PRODUÇÃO!)

# Configuração de Portas
POSTGRES_PORT=5432                   # Porta externa do PostgreSQL
PGADMIN_PORT=8080                   # Porta da interface web do pgAdmin
```

> ⚠️ **Aviso de Segurança**: Sempre altere as senhas padrão em ambientes de produção!

## 🚀 Começando

### 1. Clonar e Configurar

```bash
# Clone o repositório, preferencialmente com SSH para segurança

# SSH
git clone git@github.com:Cardosofiles/postgresql-database-course.git
cd database/postgreSQL

#HTTPS
git clone https://github.com/Cardosofiles/postgresql-database-course.git
cd database/postgreSQL

# Certifique-se de que o arquivo .env está configurado (veja Configuração de Ambiente acima)
ls -la .env
```

### 2. Iniciar os Serviços

```bash
# Inicia PostgreSQL e pgAdmin em segundo plano
docker-compose up -d

# Verifica se os serviços estão rodando
docker ps

# Visualiza logs (opcional)
docker-compose logs -f
```

### 3. Verificar Instalação

Aguarde o health check passar e depois verifique:

```bash
# Verifica se PostgreSQL está pronto
docker-compose exec postgres pg_isready -U postgres

# Deve retornar: postgres:5432 - accepting connections
```

## 📊 Informações de Acesso

### Banco de Dados PostgreSQL

- **Host:** `localhost` (ou IP do seu host Docker)
- **Porta:** `5432` (configurável via `POSTGRES_PORT`)
- **Banco:** `database_course` (configurável via `POSTGRES_DB`)
- **Usuário:** `postgres` (configurável via `POSTGRES_USER`)
- **Senha:** `postgres123` (configurável via `POSTGRES_PASSWORD`)

### Interface Web pgAdmin

- **URL:** http://localhost:8080 (porta configurável via `PGADMIN_PORT`)
- **Email:** `admin@admin.com` (configurável via `PGADMIN_DEFAULT_EMAIL`)
- **Senha:** `admin123` (configurável via `PGADMIN_DEFAULT_PASSWORD`)

#### Adicionando Servidor PostgreSQL no pgAdmin

1. Abra o pgAdmin em http://localhost:8080
2. Faça login com suas credenciais configuradas
3. Clique com botão direito em "Servers" → "Create" → "Server"
4. **Aba General:**
   - Name: `Local PostgreSQL`
5. **Aba Connection:**
   - Host: `postgres` (nome do serviço Docker)
   - Port: `5432`
   - Username: `postgres` (ou seu `POSTGRES_USER`)
   - Password: `postgres123` (ou seu `POSTGRES_PASSWORD`)

### Outra forma de conectar ao banco

Você também pode usar qualquer cliente SQL (DBeaver, DataGrip, TablePlus, etc.) para conectar ao banco de dados usando as mesmas credenciais acima.

Nesse tutorial, usaremos o **[Beekeeper Studio](http://beekeeperstudio.io/)** como exemplo.

1. Faça o download e instale o Beekeeper Studio Community Edition (gratuito e open-source).
2. Abra o Beekeeper Studio
3. Clique em "New Connection"
4. Selecione "PostgreSQL"
5. Preencha os campos:
   - Host: `localhost`
   - Port: `5432`
   - Database: `database_course`
   - Username: `postgres`
   - Password: `postgres123`
6. Clique em "Connect"

## 🔧 Comandos Úteis

### Operações de Banco de Dados

```bash
# Conectar ao PostgreSQL via psql
docker-compose exec postgres psql -U postgres -d database_course

# Executar comandos SQL diretamente
docker-compose exec postgres psql -U postgres -d database_course -c "SELECT version();"

# Criar um novo banco de dados
docker-compose exec postgres createdb -U postgres my_new_database
```

### Backup e Restauração

```bash
# Criar backup
docker-compose exec postgres pg_dump -U postgres database_course > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar do backup
docker-compose exec -T postgres psql -U postgres -d database_course < backup_20231215_143022.sql

# Backup com formato customizado (recomendado para bancos grandes)
docker-compose exec postgres pg_dump -U postgres -Fc database_course > backup.dump

# Restaurar formato customizado
docker-compose exec -T postgres pg_restore -U postgres -d database_course backup.dump
```

### Monitoramento e Logs

```bash
# Visualizar logs de todos os serviços
docker-compose logs -f

# Visualizar apenas logs do PostgreSQL
docker-compose logs -f postgres

# Visualizar apenas logs do pgAdmin
docker-compose logs -f pgadmin

# Monitorar uso de recursos
docker stats postgres_course_db postgres_course_pgadmin
```

### Manutenção

```bash
# Parar serviços
docker-compose down

# Parar e remover volumes (⚠️ ISSO APAGA TODOS OS DADOS!)
docker-compose down -v

# Reiniciar serviços
docker-compose restart

# Recriar containers (se você alterar configurações)
docker-compose up -d --build
```

## 📁 Estrutura do Projeto

```
database/postgreSQL/
├── docker-compose.yml      # Configuração principal do Docker Compose
├── .env                    # Variáveis de ambiente (NÃO commitar no Git)
├── .env.example           # Arquivo de exemplo de ambiente (seguro para commit)
├── init-scripts/          # Scripts SQL executados na primeira inicialização
│   ├── 01-create-tables.sql
│   └── 02-insert-data.sql
├── backups/               # Backups do banco de dados (opcional)
└── README.md             # Este arquivo
```

### Adicionando Scripts de Inicialização

Coloque arquivos SQL no diretório `init-scripts/` para executá-los automaticamente quando o banco de dados for criado pela primeira vez:

```bash
# Criar o diretório se ele não existir
mkdir -p init-scripts

# Adicionar seus scripts de inicialização
echo "CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));" > init-scripts/01-create-tables.sql
```

## 🔒 Melhores Práticas de Segurança

### Para Desenvolvimento

- Mantenha senhas padrão para desenvolvimento local
- Use arquivo `.env` (já está no `.gitignore`)

### Para Produção

- [ ] Altere todas as senhas padrão
- [ ] Use senhas fortes e únicas
- [ ] Restrinja acesso de rede
- [ ] Habilite conexões SSL/TLS
- [ ] Backups regulares
- [ ] Monitore logs
- [ ] Use gerenciamento de secrets (Docker Secrets, Kubernetes Secrets, etc.)

Exemplo de `.env` para produção:

```properties
POSTGRES_DB=myapp_production
POSTGRES_USER=myapp_user
POSTGRES_PASSWORD=super_secure_password_here
PGADMIN_DEFAULT_EMAIL=admin@seudominio.com
PGADMIN_DEFAULT_PASSWORD=another_secure_password
POSTGRES_PORT=5432
PGADMIN_PORT=8080
```

## 🐛 Solução de Problemas

### Problemas Comuns

1. **Porta já está em uso**

   ```bash
   # Verificar o que está usando a porta
   lsof -i :5432
   # Alterar POSTGRES_PORT no arquivo .env
   ```

2. **Erros de permissão negada**

   ```bash
   # Corrigir permissões para volumes
   sudo chown -R 999:999 ./postgres_data
   ```

3. **Banco de dados não inicia**

   ```bash
   # Verificar logs
   docker-compose logs postgres
   # Remover volumes e reiniciar
   docker-compose down -v && docker-compose up -d
   ```

4. **Não consegue conectar da aplicação**
   - Use `localhost:5432` da máquina host
   - Use `postgres:5432` de outros containers Docker

### Obtendo Ajuda

- Consulte a [Documentação do PostgreSQL](https://www.postgresql.org/docs/)
- Visite a [Documentação do pgAdmin](https://www.pgadmin.org/docs/)
- Revise os logs do Docker Compose: `docker-compose logs`

## 🤝 Contribuindo

1. Faça um fork do repositório
2. Crie sua branch de feature: `git checkout -b feature/funcionalidade-incrivel`
3. Commit suas mudanças: `git commit -m 'Adiciona funcionalidade incrível'`
4. Faça push para a branch: `git push origin feature/funcionalidade-incrivel`
5. Abra um Pull Request

## 📝 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

<div align="right">

[⬆️ Voltar ao topo](#postgresql-com-docker-compose)

</div>

---

**Feito com ❤️ para a comunidade de desenvolvedores**
