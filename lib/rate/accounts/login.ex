defmodule Rate.Accounts.Login do
  @moduledoc false

  alias Rate.Accounts.User

  @token_salt Application.compile_env!(:rate, :authentication_token_salt)

  def run(token: token) do
    with {:ok, user_id} <- verify_login_token(token) do
      User.find_by(external_id: user_id)
    end
  end

  defp verify_login_token(token) do
    Phoenix.Token.verify(RateWeb.Endpoint, @token_salt, token, max_age: 86_400)
  end
end
