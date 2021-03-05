
defmodule EventsAppWeb.Plugs.UserRequired do
  use EventsAppWeb, :controller

  def init(args), do: args

  def call(conn, _args) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Log in or Register")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
