defmodule EventsAppWeb.Plugs.FetchSession do
  import Plug.Conn

  def init(args), do: args

  def call(conn, _args) do
    user_id = get_session(conn, :user_id) || -1
    user = EventsApp.Users.get_user(user_id)
    if user do
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end
end
