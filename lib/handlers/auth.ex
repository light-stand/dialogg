defmodule Dialogg.AuthHandler do
  def init(req, state) do
    token = Dialogg.TokenHandler.encode_token("1")
    # req = :cowboy_req.reply(200, %{"content-type" => "text/plain"}, token, req)
    {:ok, req, state}
  end
end
