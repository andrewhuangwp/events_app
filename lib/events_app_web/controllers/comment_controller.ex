defmodule EventsAppWeb.CommentController do
  use EventsAppWeb, :controller

  alias EventsApp.Comments
  alias EventsApp.Comments.Comment
  alias EventsApp.Events

  alias EventsAppWeb.Plugs

  plug Plugs.UserRequired when action not in [:index, :show]
  plug :invitedRequired when action in [:create]
  plug :deleterRequired when action in [:delete]
  plug :commenterRequired when action in [:update]

  def invitedRequired(conn, _opts) do
    event_id = conn.params["comment"]["event_id"]
    event = Events.get_event!(event_id)
    owner_id = event.user.id
    invites = event.invites
    current_user = conn.assigns[:current_user]

    # True if current user is event owner or invited
    if (current_user.id == owner_id) || Enum.any?(invites, fn inv -> inv.email == current_user.email end) do
      conn
    else
      conn
      |> put_flash(:error, "Only invited users or the event owner can comment.")
      |> redirect(to: Routes.event_path(conn, :show, event_id))
      |> halt()
    end
  end

  # Only commenter or owner can delete comments.
  def deleterRequired(conn, _opts) do
    comment_id = conn.params["id"]
    comment = Comments.get_comment!(comment_id)
    event_id = comment.event.id
    owner_id = Events.get_event!(comment.event_id).user.id
    current_user = conn.assigns[:current_user]

    # True if current user is event owner or commenter
    if (current_user.id == owner_id) || (current_user.id == comment.user.id) do
      conn
    else
      conn
      |> put_flash(:error, "Only the commenter and event owner can delete the comment.")
      |> redirect(to: Routes.event_path(conn, :show, event_id))
      |> halt()
    end
  end

  # Only commenter can edit comments.
  def commenterRequired(conn, _opts) do
    comment_id = conn.params["id"]
    comment = Comments.get_comment!(comment_id)
    event_id = comment.event.id
    current_user = conn.assigns[:current_user]

    if (current_user.id == comment.user.id) do
      conn
    else
      conn
      |> put_flash(:error, "Only the commenter can edit the comment.")
      |> redirect(to: Routes.event_path(conn, :show, event_id))
      |> halt()
    end
  end

  def index(conn, _params) do
    comments = Comments.list_comments()
    render(conn, "index.html", comments: comments)
  end

  def new(conn, _params) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"comment" => comment_params}) do
    event_id = comment_params["event_id"]
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Could not create comment.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))
    end
  end


  def edit(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    changeset = Comments.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)
    event_id = comment_params["event_id"]

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Could not update comment.")
        |> redirect(to: Routes.event_path(conn, :show, event_id))
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    event_id = comment.event.id
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event_id))
  end
end
