defmodule EventsAppWeb.HelperFunctions do
  def isCurrUser?(conn, user_id) do
    curr_user = conn.assigns[:current_user]
    if curr_user do
      user_id == curr_user.id
    else
      false
    end
  end
end
