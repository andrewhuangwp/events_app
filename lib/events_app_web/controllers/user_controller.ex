defmodule EventsAppWeb.UserController do
  use EventsAppWeb, :controller

  alias EventsApp.Users
  alias EventsApp.Users.User
  alias EventsAppWeb.Plugs

  plug Plugs.UserRequired when action in [:update, :edit, :delete]

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    email = user_params["email"]
    {:ok, hash} = Users.save_photo(email, user_params["photo"].path)
    user_params = Map.put(user_params, "photo_hash", hash)
    Map.delete(user_params, "photo")

    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show_photo(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _name, data} = Users.load_photo(user.photo_hash)
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, data)
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    email = user_params["email"]
    user = Users.get_user!(id)
    {:ok, hash} = Users.save_photo(email, user_params["photo"].path)
    user_params = Map.put(user_params, "photo_hash", hash)

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    case Users.delete_user(user) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Could not delete user. User must not have any events.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end
end
