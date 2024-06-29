defmodule Dialogg do
  use Application

  def start(_type, _args) do
    IO.puts("=== Starting Dialogg ===")
    children = [
      {RoomStore, RoomStore.initial_values()},
      # %{id: Scheduler, start: {Scheduler, :start, [5000]}},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Dialogg.Router,
        options: [dispatch: dispatch(), port: 5000]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Dialogg
      )
    ]
#
    opts = [strategy: :one_for_one, name: Dialogg.Application]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws/[...]", Dialogg.SocketHandler, []}
       ]}
    ]
  end
end
