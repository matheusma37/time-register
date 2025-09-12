# Time Register

Sistema para registro e acompanhamento de horários de trabalho, geração de relatórios e integração com Sidekiq para processamento assíncrono.

## Menu de Navegação
- [Descrição do projeto](#time-register)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Setup](#instalação-e-setup)
  - [Clone do repositório](#1-clone-do-repositório)
  - [Instalação de dependências](#2-instalação-de-dependências)
  - [Setup do banco de dados](#3-setup-do-banco-de-dados)
  - [Configuração de variáveis de ambiente](#4-configuração-de-variáveis-de-ambiente)
- [Como Executar](#como-executar)
  - [Desenvolvimento local](#desenvolvimento-local)
  - [Via Docker](#via-docker)
- [Execução de testes](#execução-de-testes)
- [Documentação da API](#documentação-da-api)
  - [Endpoints principais](#endpoints-principais)
    - [Usuários](#usuários)
    - [Time Logs](#time-logs)
    - [Relatórios](#relatórios)
  - [Exemplos de request/response](#exemplos-de-requestresponse)
  - [Códigos de status HTTP](#códigos-de-status-http)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
  - [Estrutura de pastas](#estrutura-de-pastas)
  - [Padrões utilizados](#padrões-utilizados)
  - [Decisões técnicas](#decisões-técnicas)
- [Testes](#testes)
  - [Como executar](#como-executar-1)
  - [Cobertura](#cobertura)
- [Deploy](#deploy)
  - [Básico](#básico)

## Pré-requisitos
- Ruby >= 3.4
- Rails >= 8.0
- PostgreSQL >= 16
- Redis >= 7
- Docker e Docker Compose (opcional para ambiente containerizado)

## Instalação e Setup

### 1. Clone do repositório
```sh
git clone https://github.com/matheusma37/time-register.git
cd time-register
```

### 2. Instalação de dependências
```sh
bundle install
```

### 3. Setup do banco de dados
```sh
bin/rails db:create db:migrate db:seed
```

### 4. Configuração de variáveis de ambiente
Crie um arquivo `.env` ou configure as variáveis:
- `POSTGRES_HOST`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `REDIS_URL`
- `APP_HOST`

## Como Executar

### Desenvolvimento local
```sh
bin/rails server
```

### Via Docker
```sh
docker-compose up --build
```

## Execução de testes
```sh
RAILS_ENV=test bundle exec rspec
```
Ou via Docker:
```sh
docker-compose run app bundle exec rspec
```

## Documentação da API

### Endpoints principais

#### Usuários
- `GET /api/v1/users` — Lista usuários
- `POST /api/v1/users` — Cria usuário
- `GET /api/v1/users/:id` — Detalha usuário
- `PATCH/PUT /api/v1/users/:id` — Atualiza usuário
- `DELETE /api/v1/users/:id` — Remove usuário
- `POST /api/v1/users/:id/reports` — Gera relatório de horários

#### Time Logs
- `GET /api/v1/time_registers` — Lista todos os registros
- `POST /api/v1/time_registers` — Cria registro de horário
- `GET /api/v1/time_registers/:id` — Detalha registro
- `PATCH/PUT /api/v1/time_registers/:id` — Atualiza registro
- `DELETE /api/v1/time_registers/:id` — Remove registro

#### Relatórios
- `GET /api/v1/reports/:process_id/status` — Status do relatório
- `GET /api/v1/reports/:process_id/download` — Download do relatório

### Exemplos de request/response

**Listar usuários**
```http
GET /api/v1/users
```
**Response:**
```json
[
  { "id": 1, "name": "João", "email": "joao@email.com" },
  { "id": 2, "name": "Maria", "email": "maria@email.com" }
]
```

**Criar usuário**
```http
POST /api/v1/users
{
  "user": { "name": "João", "email": "joao@email.com" }
}
```
**Response:**
```json
{
  "id": 1,
  "name": "João",
  "email": "joao@email.com"
}
```

**Detalhar usuário**
```http
GET /api/v1/users/1
```
**Response:**
```json
{
  "id": 1,
  "name": "João",
  "email": "joao@email.com"
}
```

**Atualizar usuário**
```http
PATCH /api/v1/users/1
{
  "user": { "name": "João da Silva", "email": "joao.silva@email.com" }
}
```
**Response:**
```json
{
  "id": 1,
  "name": "João da Silva",
  "email": "joao.silva@email.com"
}
```

**Remover usuário**
```http
DELETE /api/v1/users/1
```
**Response:**
Status 204 No Content

**Gerar relatório de horários**
```http
POST /api/v1/users/1/reports
{
  "start_date": "2024-06-01",
  "end_date": "2024-06-30"
}
```
**Response:**
```json
{
  "process_id": "abc123",
  "status": "queued"
}
```

**Listar time_registers**
```http
GET /api/v1/time_registers
```
**Response:**
```json
[
  { "id": 1, "user_id": 1, "clock_in": "2024-06-01T08:00:00Z", "clock_out": "2024-06-01T18:00:00Z" },
  { "id": 2, "user_id": 1, "clock_in": "2024-06-02T08:05:00Z", "clock_out": "2024-06-02T18:10:00Z" }
]
```

**Criar time_register**
```http
POST /api/v1/time_registers
{
  "time_register": { "user_id": 1, "clock_in": "2024-06-01T08:00:00Z", "clock_out": "2024-06-01T18:00:00Z" }
}
```
**Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "clock_in": "2024-06-01T08:00:00Z",
  "clock_out": "2024-06-01T18:00:00Z"
}
```

**Detalhar time_register**
```http
GET /api/v1/time_registers/1
```
**Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "clock_in": "2024-06-01T08:00:00Z",
  "clock_out": "2024-06-01T18:00:00Z"
}
```

**Atualizar time_register**
```http
PATCH /api/v1/time_registers/1
{
  "time_register": { "clock_in": "2024-06-01T08:10:00Z", "clock_out": "2024-06-01T18:05:00Z" }
}
```
**Response:**
```json
{
  "id": 1,
  "user_id": 1,
  "clock_in": "2024-06-01T08:10:00Z",
  "clock_out": "2024-06-01T18:05:00Z"
}
```

**Remover time_register**
```http
DELETE /api/v1/time_registers/1
```
**Response:**
Status 204 No Content

**Status do relatório**
```http
GET /api/v1/reports/abc123/status
```
**Response:**
```json
{
  "process_id": "abc123",
  "status": "completed",
  "progress": 100.0
}
```

**Download do relatório**
```http
GET /api/v1/reports/abc123/download
```
**Response:**
Redirect para URL do arquivo CSV

### Códigos de status HTTP
- 200 OK — Sucesso
- 201 Created — Recurso criado
- 202 Accepted — Processamento assíncrono iniciado
- 400 Bad Request — Erro de validação
- 404 Not Found — Recurso não encontrado
- 422 Unprocessable Entity — Erro de processamento

## Arquitetura do Projeto

### Estrutura de pastas
- `app/controllers` — Controllers da API
- `app/models` — Modelos de dados
- `app/jobs` — Jobs do Sidekiq
- `spec/` — Testes automatizados
- `config/` — Configurações do Rails e Sidekiq
- `db/` — Migrations e seeds

### Padrões utilizados
- Rails API Only
- Sidekiq para jobs assíncronos
- Active Storage para arquivos
- FactoryBot e Faker para testes e seeds

### Decisões técnicas
- Utilização de Docker para facilitar setup e deploy
- Redis para filas do Sidekiq
- PostgreSQL como banco principal
- Testes automatizados com RSpec
- Armazenamento local dos arquivos de relatório gerados

## Testes

### Como executar
```sh
bundle exec rspec
```

### Cobertura
Veja o relatório em: [coverage/index.html](coverage/index.html)

Relatórios de cobertura podem ser gerados com SimpleCov.
Para isso, execute o comando `bundle exec rspec`.

## Deploy

### Básico
- Configure variáveis de ambiente para produção
- Execute as migrations: `bin/rails db:migrate`
- Inicie o servidor: `bin/rails server -e production`
- Para deploy containerizado, utilize o Dockerfile de produção e configure volumes e variáveis conforme necessário.
