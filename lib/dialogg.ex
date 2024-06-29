defmodule Dialogg do
  alias Dialogg.Mnesia
  use Application

  def start(_type, _args) do
    IO.puts("=== Starting Dialogg ===")

    :ok = Mnesia.setup()
    children = [
      Dialogg.Repo,
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
         {"/ws/:token", Dialogg.SocketHandler, []}
       ]}
    ]
  end
end
