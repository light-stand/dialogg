defmodule Dialogg.Room do
  use Ecto.Schema
  import Ecto.Changeset

  ### Room Schema
  schema "rooms" do
    field :created_at, :naive_datetime

    has_many :user_rooms, Dialogg.UserRoom
    has_many :users, through: [:user_rooms, :user]
  end

  @doc false
  def room_changeset(room, attrs) do
    room
    |> cast(attrs, [])
    |> validate_required([])
  end
end
