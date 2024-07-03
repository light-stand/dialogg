defmodule Dialogg.SocketHandler do
  require Logger
  alias Dialogg.Mnesia

  # Not run in the same process as the Websocket callbacks.
  def init([token]) do
    user = load_user_from_request(token)
    IO.inspect(user, label: "User")
    state = %{
      rooms: user.rooms,
      user: user.id
    }

    Registry.Dialogg |> Registry.register("room_broadcast", %{user: state.user})
    Mnesia.register_user(state)
    :mnesia.dirty_all_keys(:user_rooms) |> IO.inspect(label: "Mnesia Keys")

    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime})

    {:ok, state}
  end

  # websocket_init: Called once the connection has been upgraded to Websocket.
  def websocket_init(state) do
    Registry.Dialogg |> Registry.register("room_broadcast", %{user: state.user})
    Mnesia.register_user(state)
    :mnesia.dirty_all_keys(:user_rooms) |> IO.inspect(label: "Mnesia Keys")

    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime})
    {:reply, {:text, json}, state}
  end

  def handle_in({:text, json}, state) do
    message = Map.merge(Jason.decode!(json), %{"user" => state.user})
    Message.broadcast(message)
    {:reply, :ok, {:text, json}, state}
  end


  def websocket_info({:broadcast, message}, state) do
    {:reply, {:text, message}, state}
  end

  def terminate(:timeout, state) do
    Mnesia.unregister_user(state)
    {:ok, state}
  end

  def load_user_from_request(token) do
    require Ecto.Query
    {:ok, claims} = Dialogg.TokenHandler.decode_token(token)
    user_id = claims["sub"]

    rooms = Dialogg.UserRoom
    |> Ecto.Query.where([r], r.user_id == ^user_id)
    |> Ecto.Query.select([r], {r.room_id})
    |> Dialogg.Repo.all
    |> Enum.map(fn {elem} -> elem end)

    %{
      id: user_id,
      rooms: rooms
    }
  end
end
