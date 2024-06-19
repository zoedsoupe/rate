defmodule RateWeb.Router do
  use RateWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RateWeb do
    pipe_through :api
  end
end
