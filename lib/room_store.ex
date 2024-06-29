# defmodule Quote do

#   @derive {Jason.Encoder, only: [:symbol, :name, :price, :share, :arrow, :dif, :difp]}
#   defstruct [:symbol, :name, :price, :share, :arrow, :dif, :difp]


#   def new({symbol, name, price, share}) do # I love C++
#     %Quote{symbol: symbol, name: name, price: price, share: share}
#   end
# end


defmodule RoomStore do
  use Agent

  def initial_values() do
    %{
      users_by_room: %{},
      rooms_by_user: %{},
    }
  end

  def start_link(rooms) do
    Agent.start_link(fn -> rooms end, name: __MODULE__)
  end

  def values do
    Agent.get(__MODULE__, & &1)
  end

  def get_user_rooms(user) do
    values().rooms_by_user[user] || []
  end

  def get_room_users(room) do
    values().users_by_room[String.to_atom(room)] || []
  end

  def update do
    values = Enum.map(Agent.get(__MODULE__, & &1), fn q -> q end) # TODO
    Agent.update(__MODULE__, fn _ -> values end)
    values
  end

  def register_user(ws_state) do
    IO.inspect(ws_state, label: "WS_STATE")
    Agent.update(__MODULE__, fn state ->
      rooms_by_user = Map.put(state.rooms_by_user, ws_state.user, ws_state.rooms)
      users_by_room = Enum.reduce(ws_state.rooms, state.users_by_room, fn room, acc ->
        room_atom = String.to_atom(room)
        if Map.has_key?(acc, room_atom) do
          Map.update!(acc, room_atom, &[ws_state.user | &1])
        else
          Map.put(acc, room_atom, [ws_state.user])
        end
      end)

      IO.inspect(rooms_by_user, label: "rooms_by_user")
      IO.inspect(users_by_room, label: "users_by_room")

      %{
        rooms_by_user: rooms_by_user,
        users_by_room: users_by_room
      }
    end)
  end

  def unregister_user(ws_state) do
    Agent.update(__MODULE__, fn state ->
      rooms_by_user = Map.delete(state.rooms_by_user, ws_state.user)
      users_by_room = Enum.reduce(ws_state.rooms, state.users_by_room, fn room, acc ->
        room_atom = String.to_atom(room)
        if Map.has_key?(acc, room_atom) do
          updated_room_users = List.delete(acc[room_atom], ws_state.user)
          if updated_room_users != [] do
            Map.put(acc, room_atom, updated_room_users)
          else
            Map.delete(acc, room_atom)
          end
        else
          acc
        end
      end)

      IO.inspect(rooms_by_user, label: "rooms_by_user")
      IO.inspect(users_by_room, label: "users_by_room")

      %{
        rooms_by_user: rooms_by_user,
        users_by_room: users_by_room
      }
    end)
  end
end
