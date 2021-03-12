defmodule EventsApp.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :naive_datetime
    field :desc, :string
    field :name, :string

    belongs_to :user, EventsApp.Users.User

    has_many :invites, EventsApp.Invites.Invite, on_delete: :delete_all
    has_many :comments, EventsApp.Comments.Comment, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:date, :name, :desc, :user_id])
    |> validate_required([:date, :name, :desc, :user_id])
  end
end
