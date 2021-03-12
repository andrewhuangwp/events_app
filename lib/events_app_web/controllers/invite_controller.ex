defmodule EventsAppWeb.InviteController do
  use EventsAppWeb, :controller

  alias EventsApp.Invites
  alias EventsApp.Invites.Invite
  alias EventsAppWeb.Plugs
  alias EventsApp.Events
  alias EventsApp.Users

  def ownerRequired(conn, _params) do
    event_id = conn.params["invite"]["event_id"]
    owner_id = Events.get_event!(event_id).user.id
    current_user = conn.assigns[:current_user]

    if current_user.id == owner_id do
      conn
    else
      conn
      |> put_flash(:error, "Only the event owner can invite or delete invites.")
      |> redirect(to: Routes.event_path(conn, :show, event_id))
      |> halt()
     end
  end

  # Only the invited or the event host is required
  def invitedRequired(conn, _params) do
    event_id = conn.params["invite"]["event_id"]
    owner_id = Events.get_event!(event_id).user.id
    invited_id = Users.get_user_by_email(conn.params["invite"]["email"]).id
    current_user_id = conn.assigns[:current_user].id

    if (current_user_id == owner_id) || (current_user_id == invited_id) do
      conn
    else
      conn
      |> put_flash(:error, "Only the event host or invited user can modify the invite.")
      |> redirect(to: Routes.event_path(conn, :show, event_id))
     end
  end

  def index(conn, _params) do
    invites = Invites.list_invites()
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invite" => invite_params}) do
    event_id = invite_params["event_id"]
    if Invites.get_invited(event_id, invite_params["email"]) do
      conn
      |> put_flash(:info, "User already invited. Invite link: http://events.normalwebiste.art/events/#{event_id}")
      |> redirect(to: Routes.event_path(conn, :show, event_id))
    else
      case Invites.create_invite(invite_params) do
        {:ok, invite} ->
          conn
          |> put_flash(:info, "User successfully invited. Invite link: http://events.normalwebiste.art/events/#{event_id}")
          |> redirect(to: Routes.event_path(conn, :show, event_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_flash(:error, "Unable to create invite.")
          |> redirect(to: Routes.event_path(conn, :show, event_id))
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    changeset = Invites.change_invite(invite)
    render(conn, "edit.html", invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    invite = Invites.get_invite!(id)
    event_id = invite_params["event_id"]

    case Invites.update_invite(invite, invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Unable to update invite.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    event_id = invite.event_id
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event_id))
  end
end
