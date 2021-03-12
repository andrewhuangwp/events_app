defmodule EventsAppWeb.EventController do
  use EventsAppWeb, :controller

  alias EventsApp.Events
  alias EventsApp.Events.Event
  alias EventsApp.Comments
  alias EventsApp.Invites
  alias EventsAppWeb.Plugs

  plug Plugs.UserRequired when action not in []
  plug :ownerRequired when action in [:edit, :update, :delete]
  plug :fetchEvent when action not in [:index, :new, :create]
  plug :invitedRequired when action not in [:index, :new, :create]

  def ownerRequired(conn, _params) do
    current_user = conn.assigns[:current_user]
    id = conn.params["id"]
    event = Events.get_event!(id)

    if current_user.id == event.user.id do
      conn
    else
      conn
      |> put_flash(:error, "Only the owner of the event may modify the event.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end


  def invitedRequired(conn, _params) do
    current_user = conn.assigns[:current_user]
    id = conn.params["id"]
    event = Events.get_event!(id)
    invites = Invites.list_invites()
    invited = Enum.any?(invites, fn inv -> inv.email == current_user.email end)

    if (current_user.id == event.user.id || invited) do
      conn
    else
      conn
      |> put_flash(:error, "Only the owner of the event or invited users may see the event.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def fetchEvent(conn, _params) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    invites = EventsApp.Users.list_invites(current_user)
    owned = current_user.events
    render(conn, "index.html", invites: invites, owned: owned)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params = event_params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)

    invite = %Invites.Invite{
      event_id: event.id,
    }
    newInvite = Invites.change_invite(invite)
    comment = %Comments.Comment {
      event_id: event.id
    }
    newComment = Comments.change_comment(comment)
    responseCount = Events.load_invites(event)
    render(conn, "show.html", event: event, newInvite: newInvite, newComment: newComment, responseCount: responseCount )
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
