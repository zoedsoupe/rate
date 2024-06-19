defmodule RateWeb.TransactionController do
  @moduledoc false

  use RateWeb, :controller

  import Peri

  alias Rate.Transactions.RegisterTransaction

  defschema(:register_params, %{
    from_currency: {:required, :string},
    from_amount: {:required, :float},
    to_currency: {:required, :string}
  })

  def register(conn, params) do
    current_user = conn.assigns.current_user

    with {:ok, data} <- register_params(params),
         data = Map.put(data, :current_user, current_user),
         {:ok, trx} <- RegisterTransaction.run(data) do
      conn
      |> put_status(:created)
      |> json(%{data: trx})
    end
  end

  def list(conn, _params) do
    conn
  end
end
