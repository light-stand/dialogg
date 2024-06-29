defmodule Message do
  # def start(interval) do
  #   IO.inspect(self(), label: "Scheduler Start")
  #   :timer.apply_interval(interval, __MODULE__, :send_quotes, [])
  #   {:ok, self()}
  # end

  def broadcast(message) do
    IO.inspect(message, label: "Broadcast message")

    users_to_broadcast = RoomStore.get_room_users(message["room"])
    IO.inspect(users_to_broadcast, label: "Broadcast to users")

    serialized_message = Jason.encode!(message)

    Registry.Dialogg
    |> Registry.dispatch("room_broadcast", fn entries ->
      for {pid, %{user: user}} <- entries, user in users_to_broadcast do
        send(pid, {:broadcast, serialized_message})
      end
    end)
  end
end
