defmodule EventsApp.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :date, :naive_datetime, null: false
      add :name, :string, null: false
      add :desc, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:events, [:user_id])
  end
end
