defmodule Dialogg.User do
  use Ecto.Schema
  import Ecto.Changeset

  ### User Schema
  schema "users" do
    field :created_at, :naive_datetime

    has_many :user_rooms, Dialogg.UserRoom
    has_many :rooms, through: [:user_rooms, :room]
  end

  @doc false
  def user_changeset(user, attrs) do
    user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
