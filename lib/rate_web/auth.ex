defmodule RateWeb.Auth do
  @moduledoc false

  use RateWeb, :controller

  alias Rate.Accounts.User

  action_fallback RateWeb.FallbackController

  @token_salt Application.compile_env!(:rate, :authentication_token_salt)

  @doc """
  Retrieves the current user from the session or a signed cookie, assigning it to the connection's assigns.

  Can be easily used as a plug, for example inside a Phoenix web app
  pipeline in your `YourAppWeb.Router`, you can do something like:
  ```
  pipeline :browser do
    plug :fetch_current_user # rest of plug chain...
  end
  ```
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && fetch_user_from_token(user_token)
    assign(conn, :current_user, user)
  end

  defp fetch_user_from_token(user_token) do
    if user_id = verify_token(user_token) do
      case User.find_by(external_id: user_id) do
        {:ok, user} -> user
        {:error, _} -> nil
      end
    end
  end

  defp verify_token(token) do
    case Phoenix.Token.verify(RateWeb.Endpoint, @token_salt, token) do
      {:ok, token} -> token
      {:error, _} -> nil
    end
  end

  defp ensure_user_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {token, conn}
      _ -> {nil, conn}
    end
  end

  @doc """
  Ensures an user is authenticated before executing the rest of Plugs chain.

  Generaly you wan to use it inside your scopes routes inside `YourAppWeb.Router`:
  ```
  scope "/" do
    pipe_trough [:browser, :require_authenticated_user]

    get "/super-secret", SuperSecretController, :secret
  end
  ```
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      {:error, :unauthorized}
    end
  end
end
