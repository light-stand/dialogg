defmodule Dialogg.Repo do
  use Ecto.Repo,
    otp_app: :dialogg,
    adapter: Ecto.Adapters.Postgres
end
