defmodule EventsAppWeb.PageController do
  use EventsAppWeb, :controller

  def index(conn, _params) do
    users = EventsApp.Users.list_users()
    current_user = conn.assigns[:current_user]
    if current_user != nil do
      events = EventsApp.Users.list_invites(current_user)
      owned = current_user.events
      render(conn, "index.html", users: users, events: events, owned: owned)
    else
      render(conn, "index.html", users: users, events: %{}, owned: %{})
    end
  end
end
