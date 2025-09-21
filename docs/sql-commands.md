# Guia Prático de Comandos SQL (PostgreSQL)

Este guia lista os comandos SQL mais usados para criar, consultar e administrar bancos de dados no PostgreSQL, com exemplos práticos.

Observação

- Execute os comandos em um cliente SQL (pgAdmin, Beekeeper, psql).
- Adapte nomes de banco, schema, tabelas e colunas ao seu contexto.

Sumário

- DDL (Definição de Estruturas)
- DML (Manipulação de Dados)
- Consultas e Junções (JOINs)
- Índices
- Constraints
- Views e Materialized Views
- Sequências e Identidade
- Transações
- Funções úteis e Expressões
- JSON/JSONB e Arrays
- CTEs e Recursividade
- Full-Text Search (básico)
- Privilégios e Segurança
- Performance e Planejamento

## DDL (Definição de Estruturas)

Criar/Alterar/Excluir Banco

```sql
CREATE DATABASE mydb WITH OWNER postgres TEMPLATE template1 ENCODING 'UTF8';
ALTER DATABASE mydb RENAME TO mydb_prod;
DROP DATABASE IF EXISTS mydb;
```

Schema

```sql
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION postgres;
ALTER SCHEMA app RENAME TO core;
DROP SCHEMA IF EXISTS core CASCADE; -- CASCADE remove dependências
```

Tabela (com tipos e constraints)

```sql
CREATE TABLE IF NOT EXISTS public.users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name TEXT NOT NULL,
  age SMALLINT CHECK (age >= 0),
  balance NUMERIC(12,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Alterações em Tabela

```sql
ALTER TABLE public.users ADD COLUMN last_login TIMESTAMPTZ;
ALTER TABLE public.users ALTER COLUMN name TYPE VARCHAR(200);
ALTER TABLE public.users RENAME COLUMN name TO full_name;
ALTER TABLE public.users DROP COLUMN last_login;
ALTER TABLE public.users ADD CONSTRAINT users_email_unique UNIQUE (email);
```

Excluir/Truncar

```sql
TRUNCATE TABLE public.users;               -- limpa dados
DROP TABLE IF EXISTS public.users CASCADE; -- remove tabela
```

## DML (Manipulação de Dados)

INSERT

```sql
INSERT INTO public.users (email, full_name, age) VALUES
('ada@ex.com', 'Ada Lovelace', 28),
('alan@ex.com', 'Alan Turing', 30);

-- Inserir a partir de SELECT
INSERT INTO public.audit_logs (user_id, action)
SELECT id, 'signup' FROM public.users WHERE age >= 18;

-- UPSERT (conflito -> update)
INSERT INTO public.users (email, full_name)
VALUES ('alan@ex.com', 'Alan M. Turing')
ON CONFLICT (email) DO UPDATE
SET full_name = EXCLUDED.full_name;
```

SELECT

```sql
SELECT id, email FROM public.users WHERE is_active = TRUE ORDER BY id DESC LIMIT 10 OFFSET 0;

-- Agregações
SELECT COUNT(*) AS total, AVG(age) AS avg_age FROM public.users WHERE is_active;

-- Distintos
SELECT DISTINCT age FROM public.users ORDER BY age;

-- Window functions
SELECT id, age, AVG(age) OVER () AS avg_age_all FROM public.users;
```

UPDATE

```sql
UPDATE public.users SET is_active = FALSE, updated_at = NOW() WHERE last_login < NOW() - INTERVAL '180 days';

-- UPDATE com JOIN
UPDATE public.orders o
SET total = o.total * 0.9
FROM public.users u
WHERE o.user_id = u.id AND u.is_active = TRUE;
```

DELETE

```sql
DELETE FROM public.users WHERE is_active = FALSE AND created_at < NOW() - INTERVAL '1 year';

-- DELETE com USING
DELETE FROM public.orders o
USING public.users u
WHERE o.user_id = u.id AND u.is_active = FALSE;
```

## Consultas e Junções (JOINs)

```sql
-- INNER JOIN: somente correspondências
SELECT u.id, u.email, o.id AS order_id, o.total
FROM public.users u
INNER JOIN public.orders o ON o.user_id = u.id;

-- LEFT JOIN: mantém todos os da esquerda
SELECT u.id, u.email, o.id AS order_id, o.total
FROM public.users u
LEFT JOIN public.orders o ON o.user_id = u.id;

-- RIGHT / FULL / CROSS
SELECT ... FROM a RIGHT JOIN b ON ...;
SELECT ... FROM a FULL OUTER JOIN b ON ...;
SELECT ... FROM a CROSS JOIN b;
```

## Índices

```sql
-- Índice B-Tree padrão
CREATE INDEX idx_users_email ON public.users (email);

-- Índice único
CREATE UNIQUE INDEX users_email_uindex ON public.users (email);

-- Índice em expressão
CREATE INDEX idx_users_lower_email ON public.users ((LOWER(email)));

-- Índice GIN para JSONB
CREATE INDEX idx_profiles_data_gin ON public.profiles USING GIN (data);

-- Criar sem bloquear tanto (grandes tabelas)
CREATE INDEX CONCURRENTLY idx_orders_created_at ON public.orders (created_at);

-- Remover índice
DROP INDEX IF EXISTS public.idx_users_email;
```

## Constraints

```sql
-- PRIMARY KEY composta
ALTER TABLE public.order_items
ADD CONSTRAINT order_items_pk PRIMARY KEY (order_id, item_id);

-- FOREIGN KEY
ALTER TABLE public.orders
ADD CONSTRAINT orders_user_fk
FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

-- CHECK avançado
ALTER TABLE public.users
ADD CONSTRAINT age_range_chk CHECK (age BETWEEN 0 AND 130);

-- DEFERRABLE (validação adiada até COMMIT)
ALTER TABLE public.orders
ADD CONSTRAINT total_non_negative CHECK (total >= 0) DEFERRABLE INITIALLY DEFERRED;
```

## Views e Materialized Views

```sql
-- View
CREATE OR REPLACE VIEW public.active_users AS
SELECT id, email, full_name FROM public.users WHERE is_active = TRUE;

-- Materialized View (armazena resultado)
CREATE MATERIALIZED VIEW public.sales_by_day AS
SELECT DATE(created_at) AS day, SUM(total) AS sales
FROM public.orders
GROUP BY 1;

REFRESH MATERIALIZED VIEW public.sales_by_day;
DROP VIEW IF EXISTS public.active_users;
DROP MATERIALIZED VIEW IF EXISTS public.sales_by_day;
```

## Sequências e Identidade

```sql
-- Sequência explícita
CREATE SEQUENCE public.seq_invoice START 1000 INCREMENT 1;
SELECT nextval('public.seq_invoice');
ALTER SEQUENCE public.seq_invoice RESTART WITH 2000;
DROP SEQUENCE IF EXISTS public.seq_invoice;

-- Coluna identidade (preferível ao SERIAL)
CREATE TABLE public.invoices (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  number TEXT NOT NULL
);
```

## Transações

```sql
BEGIN;
  UPDATE public.accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE public.accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;

-- SAVEPOINT
BEGIN;
  SAVEPOINT sp1;
  UPDATE public.accounts SET balance = balance - 100 WHERE id = 1;
  ROLLBACK TO SAVEPOINT sp1; -- desfaz parcial
COMMIT;

-- Nível de isolamento
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

## Funções úteis e Expressões

```sql
SELECT
  COALESCE(nickname, full_name) AS display_name,
  CASE WHEN age >= 18 THEN 'adult' ELSE 'minor' END AS group,
  NULLIF(col_a, col_b) AS only_when_different
FROM public.users;

-- Filtros
SELECT * FROM public.users
WHERE email ILIKE '%@example.com'
  AND age BETWEEN 18 AND 30
  AND id IN (1,2,3);
```

## JSON/JSONB e Arrays

```sql
-- JSONB
CREATE TABLE public.profiles (id BIGSERIAL PRIMARY KEY, data JSONB NOT NULL);

-- Acesso e filtros
SELECT data->>'role' AS role FROM public.profiles;
SELECT * FROM public.profiles WHERE data @> '{"role":"admin"}';

-- Atualização
UPDATE public.profiles
SET data = jsonb_set(data, '{preferences,theme}', '"dark"', true)
WHERE id = 1;

-- Arrays
CREATE TABLE public.tags (id BIGSERIAL PRIMARY KEY, labels TEXT[] NOT NULL DEFAULT '{}');
INSERT INTO public.tags (labels) VALUES (ARRAY['sql','postgres']);
SELECT * FROM public.tags WHERE 'sql' = ANY(labels);
```

## CTEs e Recursividade

```sql
-- CTE básica
WITH recent AS (
  SELECT * FROM public.orders WHERE created_at >= NOW() - INTERVAL '7 days'
)
SELECT COUNT(*) FROM recent;

-- Recursiva (árvores/Hierarquias)
WITH RECURSIVE subordinates AS (
  SELECT id, manager_id, name, 1 AS lvl
  FROM employees WHERE id = 1
  UNION ALL
  SELECT e.id, e.manager_id, e.name, s.lvl + 1
  FROM employees e
  JOIN subordinates s ON e.manager_id = s.id
)
SELECT * FROM subordinates;
```

## Full-Text Search (básico)

```sql
-- Preparação
CREATE TABLE docs (id BIGSERIAL PRIMARY KEY, body TEXT NOT NULL, tsv TSVECTOR);
UPDATE docs SET tsv = to_tsvector('simple', body);
CREATE INDEX idx_docs_tsv ON docs USING GIN (tsv);

-- Consulta
SELECT * FROM docs WHERE tsv @@ to_tsquery('postgres & sql');

-- Gatilho para manter tsv atualizado (exemplo simples)
CREATE FUNCTION docs_tsv_trigger() RETURNS trigger AS $$
BEGIN
  NEW.tsv := to_tsvector('simple', NEW.body);
  RETURN NEW;
END $$ LANGUAGE plpgsql;

CREATE TRIGGER tsv_update BEFORE INSERT OR UPDATE ON docs
FOR EACH ROW EXECUTE FUNCTION docs_tsv_trigger();
```

## Privilégios e Segurança

```sql
-- Usuários/Roles
CREATE ROLE app_user LOGIN PASSWORD 'secret';
ALTER ROLE app_user SET search_path = public, app;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO app_user;

-- Permissões em objetos
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.users TO app_user;
GRANT USAGE, SELECT ON SEQUENCE public.users_id_seq TO app_user;

-- Permissões padrão para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
```

## Performance e Planejamento

```sql
-- Plano de execução
EXPLAIN SELECT * FROM public.orders WHERE user_id = 10;
EXPLAIN ANALYZE SELECT * FROM public.orders WHERE created_at >= NOW() - INTERVAL '1 day';

-- Locking em leituras/escritas
SELECT * FROM public.orders WHERE status = 'open' FOR UPDATE;
```

Dicas rápidas

- Prefira GENERATED AS IDENTITY a SERIAL em novas tabelas.
- Use JSONB com índice GIN para consultas eficientes.
- Crie índices em colunas usadas em filtros/junções, e em expressões (ex: LOWER(col)).
- Use transações para garantir consistência em operações multi-passos.
- Documente constraints e use CHECK para garantir regras de negócio no banco.

---

<div align="right">

[⬅️ Voltar ao README Principal](../README.md)

</div>
