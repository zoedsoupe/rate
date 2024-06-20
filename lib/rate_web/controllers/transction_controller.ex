defmodule RateWeb.TransactionController do
  @moduledoc false

  use RateWeb, :controller

  import Peri

  alias Rate.Transactions.RegisterTransaction
  alias Rate.Transactions.Transaction

  alias Rate.Money

  action_fallback RateWeb.FallbackController

  defschema(:register_params, %{
    from_currency: {:required, :string},
    from_amount: {:required, :float},
    to_currency: {:required, :string},
    fetch_latest: :boolean
  })

  def register(conn, params) do
    current_user = conn.assigns.current_user

    with {:ok, data} <- register_params(params),
         data = Map.put(data, :user, current_user),
         {:ok, trx} <- RegisterTransaction.run(data) do
      conn
      |> put_status(:created)
      |> json(%{data: trx})
    end
  end

  def list(conn, _params) do
    current_user = conn.assigns.current_user
    trxs = Transaction.list_by(user_id: current_user.id)
    data = Enum.map(trxs, &format_external_transaction/1)

    json(conn, %{data: data})
  end

  defp format_external_transaction(%Transaction{} = trx) do
    %{
      from_amount: Money.to_float(trx.from_amount),
      from_currency: trx.from_currency,
      to_currency: trx.to_currency,
      conversion_rate: trx.conversion_rate,
      timestamp: NaiveDateTime.to_iso8601(trx.inserted_at),
      id: trx.external_id,
      user_id: trx.user.external_id
    }
  end
end
