defmodule Dialogg.SocketHandler do
  @behaviour :cowboy_websocket
  require Logger

  # Not run in the same process as the Websocket callbacks.
  @spec init(any(), any()) :: {:cowboy_websocket, any(), nil, %{idle_timeout: :infinity}}
  def init(req, _state) do
    user = String.replace(:cowboy_req.path(req), "/ws/", "")
    state = %{
      rooms: RoomStore.get_user_rooms(user),
      user: user
    }
    {:cowboy_websocket, req, state, %{idle_timeout: :infinity}}
  end

  # websocket_init: Called once the connection has been upgraded to Websocket.
  def websocket_init(state) do
    IO.inspect(state)
    Registry.Dialogg |> Registry.register("room_broadcast", %{user: state.user})

    str_pid = to_string(:erlang.pid_to_list(self()))
    IO.puts("websocket_init: #{str_pid}")

    stime = String.slice(Time.to_iso8601(Time.utc_now()), 0, 8)
    {:ok, json} = Jason.encode(%{time: stime, quotes: RoomStore.values()})
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
end
