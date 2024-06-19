defmodule Rate.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """

  use RateWeb, :controller

  alias RateWeb.ErrorJSON

  def call(conn, {:error, {:unauthorized, reason}}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorJSON)
    |> render(:"401", error: reason)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorJSON)
    |> render(:"422", error: reason)
  end
end
