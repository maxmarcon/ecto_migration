import Config

config :ecto_migration, MigrationTest.Repo,
  database: "ecto_migration",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
  

config :ecto_migration,
       ecto_repos: [MigrationTest.Repo]