defmodule MigrationTest.Repo.Migrations.CreateSampleTable do
  use Ecto.Migration

  def change do
      create table("sample_table") do
        add(:name, :string)
      end
  end
end
