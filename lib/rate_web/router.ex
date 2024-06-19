defmodule RateWeb.Router do
  use RateWeb, :router

  import RateWeb.Auth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_user
  end

  scope "/api/v1", RateWeb do
    pipe_through :api

    post "/login", AuthController, :request_magic_link
  end

  scope "/api/v1", RateWeb do
    pipe_through [:api, :require_authenticated_user]

    post "/convert", TransactionController, :register
    get "/transactions", TransactionController, :list
  end
end
