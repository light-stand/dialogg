defmodule Dialogg.SocketHandler do
  alias Dialogg.Mnesia
  @behaviour :cowboy_websocket
  require Logger

  # Not run in the same process as the Websocket callbacks.
  def init(req, _state) do
    user = load_user_from_request(req)
    state = %{
      rooms: user.rooms,
      user: user.id
    }
    {:cowboy_websocket, req, state, %{idle_timeout: :infinity}}
  end

  # websocket_init: Called once the connection has been upgraded to Websocket.
  @spec websocket_init(any()) :: {:reply, {:text, binary()}, any()}
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

  # websocket_handle
  # Handle socket recieving messages.
  # Broadcast to all PIDs of users registered in the room.
  def websocket_handle({:text, json}, state) do
    message = Map.merge(Jason.decode!(json), %{"user" => state.user})
    Message.broadcast(message)
    {:reply, {:text, json}, state}
  end

  # websocket_info
  # Handle process recieving messages from broadcast.
  def websocket_info({:broadcast, message}, state) do
    {:reply, {:text, message}, state}
  end

  def terminate(_, _, state) do
    Mnesia.unregister_user(state)
    :ok
  end

  def load_user_from_request(req) do
    require Ecto.Query
    token = String.replace(:cowboy_req.path(req), "/ws/", "")
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
