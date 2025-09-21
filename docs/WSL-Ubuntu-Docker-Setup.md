# Guia Completo: WSL + Ubuntu + Docker + Docker Compose + Beekeeper 🚀

Um guia passo a passo para configurar um ambiente de desenvolvimento completo no Windows usando WSL2, Ubuntu, Docker e Beekeeper Studio para gerenciamento de banco de dados PostgreSQL.

<div align="right">

[⬅️ Voltar ao README Principal](../README.md)

</div>

## Índice

- [Pré-requisitos](#-pré-requisitos)
- [1. Instalando WSL2 + Ubuntu](#1-instalando-wsl2--ubuntu)
- [2. Configurando Docker no WSL2](#2-configurando-docker-no-wsl2)
- [3. Instalando Docker Compose](#3-instalando-docker-compose)
- [4. Instalando Beekeeper Studio](#4-instalando-beekeeper-studio)
- [5. Testando o Ambiente](#5-testando-o-ambiente)
- [6. Configuração do Projeto PostgreSQL](#6-configuração-do-projeto-postgresql)
- [7. Solução de Problemas](#7-solução-de-problemas)
- [8. Dicas e Otimizações](#8-dicas-e-otimizações)

## 🎯 Pré-requisitos

- Windows 10 versão 2004+ ou Windows 11
- Pelo menos 8GB de RAM (recomendado)
- Conexão com internet
- Direitos de administrador no Windows

## 1. Instalando WSL2 + Ubuntu

### 1.1 Habilitando WSL

Abra o **PowerShell como Administrador** e execute:

```powershell
# Habilitar WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Habilitar Máquina Virtual
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**Reinicie o computador** após executar os comandos acima.

### 1.2 Definindo WSL2 como Padrão

Após reiniciar, abra novamente o **PowerShell como Administrador**:

```powershell
# Definir WSL2 como versão padrão
wsl --set-default-version 2
```

### 1.3 Instalando Ubuntu

**Opção 1: Via Microsoft Store (Recomendado)**

1. Abra a Microsoft Store
2. Pesquise por "Ubuntu"
3. Instale "Ubuntu 22.04 LTS" ou a versão mais recente
4. Clique em "Iniciar" após a instalação

**Opção 2: Via PowerShell**

```powershell
# Instalar Ubuntu via linha de comando
wsl --install -d Ubuntu-22.04
```

### 1.4 Configuração Inicial do Ubuntu

1. Aguarde a instalação finalizar
2. Digite um **nome de usuário** (sem espaços, letras minúsculas)
3. Digite uma **senha** (ela não aparece na tela, é normal)
4. Confirme a senha

```bash
# Primeiro comando após instalação - atualizar sistema
sudo apt update && sudo apt upgrade -y
```

### 1.5 Verificando a Instalação

```bash
# Verificar versão do Ubuntu
lsb_release -a

# Verificar se está usando WSL2
wsl -l -v
```

## 2. Configurando Docker no WSL2

### 2.1 Instalando Docker Desktop (Recomendado)

**No Windows:**

1. Baixe o [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Execute o instalador
3. Durante a instalação, certifique-se que "Use WSL 2 instead of Hyper-V" esteja marcado
4. Reinicie o computador
5. Abra o Docker Desktop
6. Vá em **Settings** → **General** → Marque "Use the WSL 2 based engine"
7. Vá em **Settings** → **Resources** → **WSL Integration**
8. Marque "Enable integration with my default WSL distro"
9. Marque sua distribuição Ubuntu

### 2.2 Alternativa: Instalando Docker Diretamente no WSL

Se preferir instalar diretamente no Ubuntu:

```bash
# Remover versões antigas
sudo apt-get remove docker docker-engine docker.io containerd runc

# Instalar dependências
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Adicionar chave GPG oficial do Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Adicionar repositório
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Recarregar grupos (ou faça logout/login)
newgrp docker
```

### 2.3 Testando Docker

```bash
# Testar instalação
docker --version
docker run hello-world
```

## 3. Instalando Docker Compose

### 3.1 Se Usando Docker Desktop

O Docker Compose já vem instalado com o Docker Desktop.

### 3.2 Instalação Manual

```bash
# Baixar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dar permissão de execução
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker-compose --version
```

## 4. Instalando Beekeeper Studio

### 4.1 No Windows (Recomendado)

1. Acesse [https://www.beekeeperstudio.io/](https://www.beekeeperstudio.io/)
2. Baixe a versão para Windows
3. Execute o instalador
4. Siga as instruções de instalação

### 4.2 No Ubuntu (WSL)

```bash
# Baixar e instalar Beekeeper Studio
wget -qO - https://deb.beekeeperstudio.io/beekeeper.key | sudo apt-key add -
echo "deb https://deb.beekeeperstudio.io stable main" | sudo tee /etc/apt/sources.list.d/beekeeper-studio-app.list

sudo apt update
sudo apt install beekeeper-studio
```

### 4.3 Alternativas de Clientes de Banco

**Outras opções populares:**

- **pgAdmin** (já incluído no docker-compose)
- **DBeaver** (gratuito, multiplataforma)
- **DataGrip** (JetBrains, pago)
- **TablePlus** (pago, interface moderna)

## 5. Testando o Ambiente

### 5.1 Teste Completo do Setup

Crie um arquivo de teste:

```bash
# Criar diretório de teste
mkdir -p ~/test-environment
cd ~/test-environment

# Criar docker-compose.yml de teste
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  test-postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
    ports:
      - "5433:5432"
    volumes:
      - test_data:/var/lib/postgresql/data

volumes:
  test_data:
EOF

# Iniciar container de teste
docker-compose up -d

# Verificar se está rodando
docker-compose ps

# Testar conexão
docker-compose exec test-postgres psql -U test_user -d test_db -c "SELECT version();"

# Limpar teste
docker-compose down -v
cd ~
rm -rf ~/test-environment
```

## 6. Configuração do Projeto PostgreSQL

### 6.1 Clonando o Projeto

```bash
# Navegar para diretório home
cd ~

# Clonar o projeto (substitua pela URL do seu repositório)
git clone <url-do-repositorio>
cd database/postgreSQL

# Verificar arquivos
ls -la
```

### 6.2 Configurando Variáveis de Ambiente

```bash
# Editar arquivo .env
nano .env
```

Conteúdo do arquivo `.env`:

```properties
# Configurações do PostgreSQL
POSTGRES_DB=database_course
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123

# Configurações do pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@admin.com
PGADMIN_DEFAULT_PASSWORD=admin123

# Portas
POSTGRES_PORT=5432
PGADMIN_PORT=8080
```

### 6.3 Iniciando o Projeto

```bash
# Iniciar serviços
docker-compose up -d

# Verificar status
docker-compose ps

# Verificar logs
docker-compose logs -f
```

### 6.4 Conectando com Beekeeper Studio

**Configurações de Conexão:**

- **Host:** `localhost`
- **Port:** `5432`
- **User:** `postgres`
- **Password:** `postgres123`
- **Database:** `database_course`

## 7. Solução de Problemas

### 7.1 WSL não Funciona

```powershell
# Verificar se WSL está habilitado
wsl --status

# Reparar WSL
wsl --shutdown
wsl --unregister Ubuntu-22.04
wsl --install -d Ubuntu-22.04
```

### 7.2 Docker não Inicia

```bash
# Verificar status do Docker
sudo systemctl status docker

# Iniciar Docker manualmente
sudo systemctl start docker

# Habilitar auto-inicialização
sudo systemctl enable docker
```

### 7.3 Porta já em Uso

```bash
# Verificar o que está usando a porta
sudo lsof -i :5432

# Ou usar netstat
sudo netstat -tlnp | grep :5432

# Matar processo se necessário
sudo kill -9 <PID>
```

### 7.4 Problemas de Permissão

```bash
# Verificar se usuário está no grupo docker
groups $USER

# Adicionar ao grupo docker
sudo usermod -aG docker $USER

# Recarregar grupos
newgrp docker

# Ou fazer logout/login completo
```

### 7.5 WSL Lento

```bash
# Criar arquivo .wslconfig no Windows (C:\Users\SeuUsuario\.wslconfig)
[wsl2]
memory=4GB
processors=2
swap=2GB
```

### 7.6 Docker Desktop Issues

1. **Restart Docker Desktop**
2. **Reset to Factory Defaults** (Settings → Reset)
3. **Update Docker Desktop**
4. **Check Windows Updates**

## 8. Dicas e Otimizações

### 8.1 Configurações Úteis do WSL

```bash
# Arquivo ~/.bashrc - adicionar ao final
echo 'alias ll="ls -la"' >> ~/.bashrc
echo 'alias dc="docker-compose"' >> ~/.bashrc
echo 'alias dps="docker ps"' >> ~/.bashrc
echo 'alias dlogs="docker logs"' >> ~/.bashrc

# Recarregar configurações
source ~/.bashrc
```

### 8.2 Git Configuration

```bash
# Configurar Git
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# Configurar editor padrão
git config --global core.editor nano
```

### 8.3 Melhorando Performance

```bash
# Criar arquivo de configuração WSL
# No Windows: C:\Users\SeuUsuario\.wslconfig
[wsl2]
memory=6GB
processors=4
localhostForwarding=true
```

### 8.4 Backup e Restore

```bash
# Backup do ambiente WSL
wsl --export Ubuntu-22.04 C:\backup\ubuntu-backup.tar

# Restore do backup
wsl --import Ubuntu-22.04-Restored C:\wsl\ubuntu-restored C:\backup\ubuntu-backup.tar
```

### 8.5 Comandos Úteis

```bash
# Ver consumo de espaço no WSL
df -h

# Limpar containers não utilizados
docker system prune -a

# Ver estatísticas dos containers
docker stats

# Acessar container em execução
docker-compose exec postgres bash

# Ver logs específicos
docker-compose logs postgres -f

# Restart específico de serviço
docker-compose restart postgres
```

## 9. Fluxo de Trabalho Diário

### 9.1 Iniciando o Dia

```bash
# 1. Abrir terminal Ubuntu
# 2. Navegar para projeto
cd ~/database/postgreSQL

# 3. Verificar status
docker-compose ps

# 4. Iniciar se necessário
docker-compose up -d

# 5. Verificar logs
docker-compose logs -f --tail=50
```

### 9.2 Finalizando o Dia

```bash
# Parar serviços (mantém dados)
docker-compose down

# Ou manter rodando (recomendado para desenvolvimento)
# Os containers continuam rodando até restart do Windows
```

## 10. Recursos Adicionais

### 10.1 Documentação Oficial

- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### 10.2 Extensões Úteis VS Code

- **WSL** - Para trabalhar diretamente no WSL
- **Docker** - Gerenciar containers
- **PostgreSQL** - Syntax highlighting para SQL
- **GitLens** - Melhor integração com Git

### 10.3 Comunidades e Suporte

- [Docker Community](https://www.docker.com/community)
- [PostgreSQL Community](https://www.postgresql.org/community/)
- [WSL GitHub](https://github.com/microsoft/WSL)

## 🚀 Próximos Passos

Após configurar o ambiente:

1. ✅ Teste a conexão com Beekeeper Studio
2. ✅ Explore o pgAdmin em http://localhost:8080
3. ✅ Crie suas primeiras tabelas e dados
4. ✅ Configure backup automático
5. ✅ Explore ferramentas de monitoramento

<div align="right">

[⬆️ Voltar ao topo](#índice)

</div>

---

**Feito com ❤️ para a comunidade**

> 💡 **Dica:** Marque este repositório com ⭐ se foi útil para você e compartilhe com outros desenvolvedores!

<div align="right">

[⬅️ Voltar ao README Principal](../README.md)

</div>
