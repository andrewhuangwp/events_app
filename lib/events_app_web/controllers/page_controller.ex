defmodule EventsAppWeb.PageController do
  use EventsAppWeb, :controller

  def index(conn, _params) do
    users = EventsApp.Users.list_users()
    events = EventsApp.Events.list_events()
    render(conn, "index.html", users: users, events: events)
  end
end
