defmodule Dialogg.Token do
  use Joken.Config

  @impl true
  def token_config do
    default_claims()
  end

  def signer do
    Joken.Signer.create("HS256", "dialogg_secret") # TODO
  end

end

defmodule Dialogg.TokenHandler do
  def decode_token(token) do
    signer = Dialogg.Token.signer()
    Dialogg.Token.verify_and_validate(token, signer)
  end
  def encode_token(user_id) do
    signer = Dialogg.Token.signer()
    Dialogg.Token.generate_and_sign(%{"sub" => user_id}, signer)
  end
end
