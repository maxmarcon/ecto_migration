# Possible bug in ecto.migrate command when used with --prefix options

## Environment

* Elixir: 1.12.2
* Erlang/OTP: 24
* Postgres: 13-alpine running in docker container
* OS: MacOS 11.4
* Dependencies:
  * ecto: 3.7.0
  * ecto_sql: 3.7.0
  * postgrex: 0.15.10
  * Others: see `mix.lock` file
  
## Expected behavior

`mix ecto.migrate --prefix private` should create a `schema_migrations` table under the `private` prefix and run all migrations under the `private` prefix.

## Steps to reproduce:

1. `mix deps.get`
2. `doocker compose up -d`
3. `mix ecto.create`
4. Create schema `private`. You can use your favorite DB client or psql with: 
   1. `psql -h localhost -U postgres ecto_migration` 
   2. Enter `postgres` as password  
   3. `CREATE SCHEMA private;`
5. `mix ecto.migrate --prefix private`

## Expected behavior

1. `schema_migrations` and `sample_table` are created in the `private` schema
2. `schema_migrations` contains the timestamp of the migration that created `sample_table`

### Actual behavior

1. `schema_migrations` is created in the `private` schema
2. `sample_table` has not been created
3. `schema_migrations` is empty
4. `mix ecto.migrate` fails with the error: 

```
** (MatchError) no match of right hand side value: {:error, %Postgrex.Error{connection_id: 5373, message: nil, postgres: %{code: :undefined_table, file: "namespace.c", line: "431", message: "relation \"schema_migrations\" does not exist", pg_code: "42P01", routine: "RangeVarGetRelidExtended", severity: "ERROR", unknown: "ERROR"}, query: nil}}
(ecto_sql 3.7.0) lib/ecto/adapters/postgres.ex:220: anonymous fn/3 in Ecto.Adapters.Postgres.lock_for_migrations/3
(ecto_sql 3.7.0) lib/ecto/adapters/sql.ex:1013: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4
(db_connection 2.4.0) lib/db_connection.ex:1512: DBConnection.run_transaction/4
(ecto_sql 3.7.0) lib/ecto/adapters/postgres.ex:215: Ecto.Adapters.Postgres.lock_for_migrations/3
(ecto_sql 3.7.0) lib/ecto/migrator.ex:493: Ecto.Migrator.lock_for_migrations/4
(ecto_sql 3.7.0) lib/ecto/migrator.ex:388: Ecto.Migrator.run/4
(ecto_sql 3.7.0) lib/ecto/migrator.ex:146: Ecto.Migrator.with_repo/3
(ecto_sql 3.7.0) lib/mix/tasks/ecto.migrate.ex:133: anonymous fn/5 in Mix.Tasks.Ecto.Migrate.run/2
```

### Observations

`mix ecto.migrate --prefix private` only works if there already is a `schema_migrations` table in the `public` prefix.
The error suggests that Ecto is trying to lock the `schema_migrations` table in the `public` prefix. Since there is none there, Ecto is raises an error.

In fact, If a `schema_migrations` table exists in the `public` schema, the migration command with prefix succeeds.
Note that the structure or content of this table is irrelevant, it can just be a dummy table created with `create table schema_migrations ();`
This suggests that ecto is simply trying to lock the `schema_migrations` table in the wrong schema (`public`) before running the migration.
