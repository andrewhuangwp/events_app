# EventsApp

Attribution: Prof. Tuck's Photo blog repo, Flatpickr, Bootstrap Documentation

Design Decisions:
* Login using only email
* Anyone can create a user. Only users can edit or delete their profile.
* Only users can create events
* Profile picture is required when creating a user. Assumes user will input correct file type and size. If file size is too large phoenix will error. Profile photo will be resized when displayed and will attempt to display photo even if file type is invalid (e.g. pdf) in which case a missing image placeholder would be displayed.
* Event Owners can invite anyone, including users who have not registered yet (no email validation for invites). Owners can invite themself to the event. Only owners can delete invitations.
* Events can take place before current date. 
* As specified, users can make multiple comments. Users can only have one invite response: each invite response overwrites the old response. If an invited user comments but gets their invite revoked their comments will stay remain on the page (comments no automatically deleted if commenter's invitation is deleted).
* Anyone who hasn't logged in cannot view any events but can view list of users. Users can only view events if they are invited or are the owner.
* Assumed that users will not delete their profile if they still own one or more event. If they try to delete, phoenix will err and delete will not go through.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
