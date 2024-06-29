defmodule Dialogg.Mnesia do
  @moduledoc """
  Mnesia setup and basic operations.
  """

  def setup do
    :mnesia.create_schema([node()])
    :mnesia.start()
    :mnesia.create_table(:user_rooms, [
      { :attributes, [:user_id, :room_id] },
      { :type, :bag },
    ])
    :mnesia.add_table_index(:user_rooms, :room_id)
    :ok
  end

  def get_user_rooms(user_id) do
    {_, records} = :mnesia.transaction(fn ->
      :mnesia.index_read(:user_rooms, user_id, :user_id)
    end)
    Enum.map(records, fn {_, _, room_id} -> room_id end)
  end

  def get_room_users(room_id) do
    {_, records} = :mnesia.transaction(fn ->
      :mnesia.index_read(:user_rooms, room_id, :room_id)
    end)
    Enum.map(records, fn {_, user_id, _} -> user_id end)
  end

  def register_user(ws_state) do
    :mnesia.transaction(fn ->
      Enum.each(ws_state.rooms, fn room_id ->
        :mnesia.write({:user_rooms, ws_state.user, room_id})
      end)
    end)
  end

  def unregister_user(ws_state) do
    IO.inspect(ws_state, label: "Unregister User")
    :mnesia.transaction(fn ->
      :mnesia.delete(:user_rooms, ws_state.user, :write)
    end)
  end
end
