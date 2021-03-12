defmodule EventsApp.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias EventsApp.Repo

  alias EventsApp.Users.User
  alias EventsApp.Invites.Invite

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def list_invites(%User{} = user) do
    invites = Repo.all(Invite) |> Repo.preload(:event)
    Enum.filter(invites, fn(invite) ->
      user.email == invite.email
    end)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload(:events)
  def get_user(id), do: Repo.get(User, id) |> Repo.preload(:events)

  def get_user_by_name(name) do
    Repo.get_by(User, name: name)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def save_photo(name, path) do
    data = File.read!(path)
    hash = sha256(data)
    meta = read_meta(hash)
    save_photo(name, data, hash, meta)
  end

  def save_photo(name, data, hash, nil) do
    File.mkdir_p!(base_path(hash))
    meta = %{
      name: name,
      refs: 0,
    }
    save_photo(name, data, hash, meta)
  end

  def save_photo(_name, data, hash, meta) do
    meta = Map.update!(meta, :refs, &(&1 + 1))
    File.write!(meta_path(hash), Jason.encode!(meta))
    File.write!(data_path(hash), data)
    {:ok, hash}
  end

  def load_photo(hash) do
    data = File.read!(data_path(hash))
    meta = read_meta(hash)
    {:ok, Map.get(meta, :name), data}
  end

  def read_meta(hash) do
    with {:ok, data} <- File.read(meta_path(hash)),
         {:ok, meta} <- Jason.decode(data, keys: :atoms)
    do
      meta
    else
      _ -> nil
    end
  end

  def base_path(hash) do
    Path.expand("~/.local/data/photo_blog")
    # |> Path.join("#{Mix.env}")
    |> Path.join(String.slice(hash, 0, 2))
    |> Path.join(String.slice(hash, 2, 30))
  end

  def meta_path(hash) do
    Path.join(base_path(hash), "meta.json")
  end

  def data_path(hash) do
    Path.join(base_path(hash), "photo.jpg")
  end

  def sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end
