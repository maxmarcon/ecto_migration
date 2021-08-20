defmodule MigrationTest.Repo do
  use Ecto.Repo,
    otp_app: :ecto_migration,
    adapter: Ecto.Adapters.Postgres
end
