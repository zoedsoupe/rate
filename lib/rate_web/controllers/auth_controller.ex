defmodule RateWeb.AuthController do
  use RateWeb, :controller

  alias Rate.Accounts.Login
  alias Rate.Accounts.RequestMagicLink

  import Peri

  action_fallback RateWeb.FallbackController

  defschema(:request_magic_link_params, %{email: {:required, :string}})

  def request_magic_link(conn, params) do
    with {:ok, data} <- request_magic_link_params(params),
         :ok <- RequestMagicLink.run(email: data.email) do
      send_resp(conn, :accepted, "")
    end
  end

  defschema(:login_params, %{token: {:required, :string}})

  def login(conn, params) do
    with {:ok, data} <- login_params(params),
         {:ok, user} <- Login.run(token: data.token) do
      conn
      |> put_status(:created)
      |> json(%{data: %{token: data.token, user_id: user.external_id}})
    else
      {:error, reason} -> {:error, {:unauthorized, reason}}
    end
  end
end
