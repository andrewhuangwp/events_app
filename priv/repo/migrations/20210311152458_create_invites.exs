defmodule EventsApp.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :status, :string, null: false
      add :email, :string, null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:invites, [:event_id])

  end
end
