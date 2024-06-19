defmodule Rate.Repo do
  use Ecto.Repo,
    otp_app: :rate,
    adapter: Ecto.Adapters.Postgres
end
