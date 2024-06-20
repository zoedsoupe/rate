defmodule RateWeb.Router do
  use RateWeb, :router

  import RateWeb.Auth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_user
  end

  scope "/api/v1", RateWeb do
    pipe_through :api

    post "/", AuthController, :login

    # when user clicks on email link
    get "/login", AuthController, :request_magic_link
    # when user send an API request
    post "/login", AuthController, :request_magic_link
  end

  scope "/api/v1", RateWeb do
    pipe_through [:api, :require_authenticated_user]

    post "/convert", TransactionController, :register
    get "/transactions", TransactionController, :list
  end
end
