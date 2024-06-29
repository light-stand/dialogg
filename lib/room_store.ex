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
    IO.puts("RoomStore.initial_values")
    users_by_room = %{
      ezenit: ["pedro", "gaston"],
      lightstand: ["david", "pedro", "gaston"],
      family: ["anderson", "pedro"]
    }

    %{
      users_by_room: users_by_room,
      rooms_by_user: transform_rooms_to_users(users_by_room)
    }
  end

  def start_link(rooms) do
    IO.puts("RoomStore.start_link, length(quotes): #{Kernel.map_size(rooms)}")
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

  def transform_rooms_to_users(rooms) do
    Enum.reduce(rooms, %{}, fn {room, users}, acc ->
      Enum.reduce(users, acc, fn user, acc_inner ->
        Map.update(acc_inner, user, [room], &[room | &1])
      end)
    end)
  end
end
