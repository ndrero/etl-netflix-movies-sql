# Netflix Data Warehouse: ELT Pipeline

Read this in: [English](#english) | [Portuguese](#portuguese)
<a name="english"></a>

This repository contains an **ELT (Extract, Load, Transform)** data pipeline that utilizes PostgreSQL to simulate a Data Warehouse environment. The project focuses on data cleaning and complex imputation using frequency-based logic.

## ELT Architecture

Unlike the traditional ETL model, where data is cleaned before entering the database, this project applies the **Transform** phase directly within the destination:

1. **Extract & Load**: Raw data from the `netflix_titles.csv` file is loaded into the `raw` schema.
2. **Transform**: SQL scripts process the data, utilizing temporary tables to calculate inferences before generating the final table in the `cleaned` schema.

## Imputation and Cleaning Logic

The project replicates advanced Python behaviors (such as `pandas` and `collections.Counter`) using pure SQL:

* **Director Imputation**: Identifies the most frequent director for the cast of movies where this field is null.
* **Country Inference**: Fills missing countries based on the filmography history of the directors (either original or inferred).
* **Rating and Duration Normalization**: Corrects a common error in the Netflix dataset where the film duration (e.g., "90 min") appears in the rating column.
* **Category-Based Voting**: Fills null ratings based on the mode (most common value) of the categories (`listed_in`) the title belongs to.

## Technologies

* **Docker**: Database orchestration.
* **PostgreSQL 16**: Processing and storage engine.
* **SQL (DML/DDL)**: Core transformation logic.

## How to Execute

1. Ensure the `data/netflix_titles.csv` file is present in the correct directory.
2. Start the database environment using `docker-compose up -d`.
3. The cleaning script will process the data automatically if placed in the `sql/` initialization folder, or it can be executed manually to generate the `cleaned.movies` table.

---

### Final Implementation Note

To ensure the script runs successfully without a stored procedure, maintain the following execution order within your SQL file:

1. **Schema Creation**: Ensure `raw` and `cleaned` exist.
2. **Data Ingestion**: `CREATE TABLE raw.movies` followed by the `COPY` command.
3. **Temporary Tables**: Create `movie_top_director`, `movie_top_country`, and `movie_top_rating`.
4. **Final Transformation**: Execute the `CREATE TABLE cleaned.movies` statement.

<a name="portuguese"></a>

# Data Warehouse Netflix: Pipeline ELT

Este repositório contém um pipeline de dados **ELT (Extract, Load, Transform)** que utiliza o PostgreSQL para simular um ambiente de Data Warehouse. O projeto foca na limpeza e imputação de dados complexos através de lógica baseada em frequência.

## Arquitetura ELT

Diferente do modelo ETL tradicional, onde os dados são limpos antes de serem inseridos no banco de dados, este projeto aplica a fase de **Transformação** diretamente no destino:

1. **Extração e Carga (Extract & Load)**: Os dados brutos do arquivo `netflix_titles.csv` são carregados no esquema `raw`.
2. **Transformação (Transform)**: Scripts SQL processam os dados, utilizando tabelas temporárias para calcular inferências antes de gerar a tabela final no esquema `cleaned`.

## Lógica de Imputação e Limpeza

O projeto replica comportamentos avançados de bibliotecas Python (como `pandas` e `collections.Counter`) utilizando SQL puro:

* **Imputação de Diretor**: Identifica o diretor mais frequente para o elenco de filmes onde este campo está nulo.
* **Inferência de País**: Preenche países ausentes com base no histórico de filmografia dos diretores (originais ou inferidos).
* **Normalização de Classificação e Duração**: Corrige um erro comum no conjunto de dados da Netflix, onde a duração do filme (ex: "90 min") aparece na coluna de classificação indicativa (`rating`).
* **Votação Baseada em Categoria**: Preenche classificações nulas com base na moda (valor mais comum) das categorias (`listed_in`) às quais o título pertence.

## Tecnologias

* **Docker**: Orquestração do banco de dados.
* **PostgreSQL 16**: Mecanismo de processamento e armazenamento.
* **SQL (DML/DDL)**: Lógica central de transformação.

## Como Executar

1. Certifique-se de que o arquivo `data/netflix_titles.csv` esteja presente no diretório correto.
2. Inicie o ambiente do banco de dados usando o comando `docker-compose up -d`.
3. O script de limpeza processará os dados automaticamente se estiver na pasta de inicialização `sql/`, ou poderá ser executado manualmente para gerar a tabela `cleaned.movies`.

---

### Nota de Implementação Final

Para garantir que o script seja executado com sucesso sem a necessidade de uma procedure armazenada, mantenha a seguinte ordem de execução dentro do seu arquivo SQL:

1. **Criação de Esquemas**: Garanta que `raw` e `cleaned` existam.
2. **Ingestão de Dados**: `CREATE TABLE raw.movies` seguido pelo comando `COPY`.
3. **Tabelas Temporárias**: Criação de `movie_top_director`, `movie_top_country` e `movie_top_rating`.
4. **Transformação Final**: Execução da instrução `CREATE TABLE cleaned.movies`.
