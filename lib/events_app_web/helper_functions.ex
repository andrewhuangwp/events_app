defmodule EventsAppWeb.HelperFunctions do
  def isCurrUser?(conn, user_id) do
    curr_user = conn.assigns[:current_user]
    if curr_user do
      user_id == curr_user.id
    else
      false
    end
  end
  def isInvited?(conn, invites) do
    curr_user = conn.assigns[:current_user]
    if curr_user do
      Enum.any?(invites, fn inv -> inv.email == curr_user.email end)
    else
      false
    end
  end
  def findInvite(conn, invites) do
    curr_user = conn.assigns[:current_user]
    if curr_user do
      Enum.find(invites, fn inv -> inv.email == curr_user.email end)
    else
      nil
    end
  end

  def commented?(conn, comments) do
    curr_user = conn.assigns[:current_user]
    if curr_user do
      comment = Enum.find(comments, fn com -> com.user_id == curr_user.id end)
    else
      nil
    end
  end
end
