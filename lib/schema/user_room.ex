defmodule Dialogg.UserRoom do
  use Ecto.Schema
  import Ecto.Changeset

  ### UserRoom Schema
  schema "user_rooms" do
    field :joined_at, :naive_datetime

    belongs_to :user, Dialogg.User, type: :string
    belongs_to :room, Dialogg.Room, type: :string
  end

  @doc false
  def user_room_changeset(user_room, attrs) do
    user_room
    |> cast(attrs, [])
    |> validate_required([])
  end
end
