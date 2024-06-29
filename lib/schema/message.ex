defmodule Dialogg.Message do
  use Ecto.Schema
  import Ecto.Changeset

  ### Message Schema
  schema "messages" do
    field :message_text, :string
    field :sent_at, :naive_datetime

    belongs_to :user, Dialogg.User, type: :string
    belongs_to :room, Dialogg.Room, type: :string
  end

  @doc false
  def message_changeset(message, attrs) do
    message
    |> cast(attrs, [:message_text])
    |> validate_required([:message_text])
  end
end
