<div align="center">

![Tipos de Dados](https://img.shields.io/badge/Curso%20de%20Banco%20de%20Dados-Rocketseat-0078D4?style=for-the-badge&logo=azuredevops)

<!-- ![Disciplina](https://img.shields.io/badge/Disciplina-ADS-4B8BBE?style=for-the-badge&logo=github) -->
<!-- ![Professora](https://img.shields.io/badge/Prof-Luciene%20Chagas%20de%20Oliveira-FFCA28?style=for-the-badge&logo=linkedin) -->

**Instituição:** [Rocketseat](https://www.rocketseat.com.br/)  
**Curso:** Banco de Dados

</div>

<div align="center">

[⬅️ Voltar ao README Principal](../README.md)

</div>

# Tipos de Dados em PostgreSQL

> Guia visual e prático dos tipos de dados suportados pelo PostgreSQL, com exemplos e dicas.

<details>
  <summary><strong>📚 Sumário (clique para expandir)</strong></summary>

- [Tipos de Dados Numéricos](#tipos-de-dados-numéricos)
- [Tipos de Dados de Texto](#tipos-de-dados-de-texto)
- [Tipos de Dados Booleanos](#tipos-de-dados-booleanos)
- [Tipos de Dados de Data e Hora](#tipos-de-dados-de-data-e-hora)
- [Tipos de Dados Binários](#tipos-de-dados-binários)
- [Tipos de Dados Geométricos](#tipos-de-dados-geométricos)
- [Tipos de Dados de Rede](#tipos-de-dados-de-rede)
- [Tipos de Dados JSON](#tipos-de-dados-json)
- [Tipos de Dados UUID](#tipos-de-dados-uuid)
- [Tipos de Dados Array](#tipos-de-dados-array)
- [Tipos de Dados HSTORE](#tipos-de-dados-hstore)
- [Tipos de Dados XML](#tipos-de-dados-xml)
- [Tipos para Busca de Texto Completo](#tipos-para-busca-de-texto-completo)
- [Conclusão](#conclusão)
</details>

## Tipos de Dados Numéricos

Tabela-resumo para escolha rápida:

| Tipo             |  Tamanho | Faixa/Precisão                 | Observações                        |
| ---------------- | -------: | ------------------------------ | ---------------------------------- |
| SMALLINT         |  2 bytes | -32,768 a 32,767               | Inteiros pequenos                  |
| INTEGER (INT)    |  4 bytes | -2,147,483,648 a 2,147,483,647 | Inteiros padrão                    |
| BIGINT           |  8 bytes | ±9.22e18                       | Inteiros grandes                   |
| REAL             |  4 bytes | ~6 dígitos                     | Ponto flutuante (precisão simples) |
| DOUBLE PRECISION |  8 bytes | ~15 dígitos                    | Ponto flutuante (precisão dupla)   |
| NUMERIC(p, s)    | variável | Exato, até 131072 dígitos      | Preciso para valores monetários    |
| SERIAL           |  4 bytes | INTEGER + sequência            | Pseudo-tipo auto-incremento        |
| BIGSERIAL        |  8 bytes | BIGINT + sequência             | Pseudo-tipo auto-incremento        |

<details>
  <summary>👀 Exemplos práticos</summary>

```sql
-- Criação de tabela com diversos tipos numéricos
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  sku VARCHAR(30) UNIQUE NOT NULL,
  stock SMALLINT DEFAULT 0,
  price NUMERIC(12,2) NOT NULL,
  rating REAL,
  weight DOUBLE PRECISION
);

-- Dica: SERIAL/BIGSERIAL criam sequência + default
-- Equivalente de SERIAL:
--   INTEGER NOT NULL DEFAULT nextval('seq_name')
--   ...e uma sequência associada com OWNED BY
```

</details>

[⬆️ Voltar ao topo](#tipos-de-dados-em-postgresql)

## Tipos de Dados de Texto

PostgreSQL oferece vários tipos de dados para armazenar texto:

- `CHAR(n)`: Armazena uma cadeia de caracteres de comprimento fixo.
- `VARCHAR(n)`: Armazena uma cadeia de caracteres de comprimento variável com um limite máximo.
- `TEXT`: Armazena uma cadeia de caracteres de comprimento variável sem limite máximo.

[⬆️ Voltar ao topo](#tipos-de-dados-em-postgresql)

## Tipos de Dados Booleanos

- `BOOLEAN`: Armazena valores booleanos (`TRUE`, `FALSE`, ou `NULL`).

[⬆️ Voltar ao topo](#tipos-de-dados-em-postgresql)

## Tipos de Dados de Data e Hora

> 💡 Dica: Prefira TIMESTAMP WITH TIME ZONE para aplicações distribuídas e sempre normalize o fuso horário na aplicação.

```sql
-- Exemplos comuns
CREATE TABLE events (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  starts_at TIMESTAMP WITH TIME ZONE NOT NULL, -- armazena instantes absolutos
  duration INTERVAL
);

-- Obter o horário atual (com fuso)
SELECT NOW();             -- TIMESTAMPTZ
SELECT CURRENT_DATE;      -- DATE
SELECT CURRENT_TIME;      -- TIME
```

[⬆️ Voltar ao topo](#tipos-de-dados-em-postgresql)

## Tipos de Dados Binários

- `BYTEA`: Armazena dados binários (bytes).

## Tipos de Dados Geométricos

PostgreSQL oferece suporte a tipos de dados geométricos para armazenar formas e pontos no espaço:

- `POINT`: Armazena um ponto no espaço 2D.
- `LINE`: Armazena uma linha infinita.
- `LSEG`: Armazena um segmento de linha.
- `BOX`: Armazena um retângulo.
- `PATH`: Armazena um caminho composto por linhas e curvas.
- `POLYGON`: Armazena um polígono.
- `CIRCLE`: Armazena um círculo.

## Tipos de Dados de Rede

PostgreSQL suporta tipos de dados para armazenar informações de rede:

- `CIDR`: Armazena um endereço de rede IPv4 ou IPv6.
- `INET`: Armazena um endereço IP (IPv4 ou IPv6).
- `MACADDR`: Armazena um endereço MAC.
- `MACADDR8`: Armazena um endereço MAC no formato EUI-64 (8 bytes).

## Tipos de Dados JSON

> ✅ Use JSONB na maioria dos casos: é indexável e mais eficiente para consultas.  
> ⚠️ JSON mantém formatação e ordem, mas não é otimizado para leitura/índices.

<details>
  <summary>👀 Exemplos práticos</summary>

```sql
-- Estrutura com JSONB
CREATE TABLE profiles (
  id BIGSERIAL PRIMARY KEY,
  data JSONB NOT NULL
);

-- Consulta por campo interno
SELECT *
FROM profiles
WHERE data->>'role' = 'admin';

-- Índice GIN para JSONB
CREATE INDEX idx_profiles_data ON profiles USING GIN (data);

-- Atualização de campo interno (merge)
UPDATE profiles
SET data = jsonb_set(data, '{preferences,theme}', '"dark"', true)
WHERE id = 1;
```

</details>

[⬆️ Voltar ao topo](#tipos-de-dados-em-postgresql)

## Tipos de Dados UUID

- `UUID`: Armazena um identificador único universal (UUID).

## Tipos de Dados Array

PostgreSQL permite a criação de colunas que armazenam arrays de qualquer tipo de dado suportado.

## Tipos de Dados HSTORE

- `HSTORE`: Armazena pares chave-valor, útil para dados semi-estruturados.
  > Observação: requer a extensão HSTORE instalada com `CREATE EXTENSION hstore;`.

## Tipos de Dados XML

- `XML`: Armazena dados XML.

## Tipos para Busca de Texto Completo

- `TSVECTOR`: Armazena um vetor de texto para pesquisa de texto completo.
- `TSQUERY`: Armazena uma consulta de texto para pesquisa de texto completo.
  > Funções úteis: `to_tsvector`, `plainto_tsquery`, `to_tsquery`.

## Conclusão

### PostgreSQL oferece uma ampla variedade de tipos de dados para atender às necessidades de diferentes aplicações. Escolher o tipo de dado correto é crucial para garantir a integridade dos dados, otimizar o desempenho e facilitar a manutenção do banco de dados. Para mais detalhes, consulte a [documentação oficial do PostgreSQL](https://www.postgresql.org/docs/current/datatype.html).
