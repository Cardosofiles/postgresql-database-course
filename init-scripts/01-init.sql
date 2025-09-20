-- Script de inicialização do banco de dados
-- Este arquivo será executado automaticamente na primeira inicialização

-- Criar extensões úteis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Criar um schema de exemplo
CREATE SCHEMA IF NOT EXISTS app;

-- Criar uma tabela de exemplo
CREATE TABLE IF NOT EXISTS app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_users_email ON app.users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON app.users(created_at);

-- Inserir dados de exemplo
INSERT INTO app.users (email, name, password_hash) 
VALUES 
    ('admin@example.com', 'Admin User', crypt('admin123', gen_salt('bf'))),
    ('user@example.com', 'Regular User', crypt('user123', gen_salt('bf')))
ON CONFLICT (email) DO NOTHING;