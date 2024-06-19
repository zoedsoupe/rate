defmodule Rate.Transactions.RegisterTransaction do
  @moduledoc false

  alias Rate.Accounts.User
  alias Rate.Transactions.Transaction
  alias Rate.Xchange

  @type params_t :: %{
          user_id: String.t(),
          from_currency: String.t(),
          from_amount: String.t(),
          to_currency: String.t(),
          fetch_latest: boolean
        }

  @spec run(params_t) :: {:ok, Transaction.t()} | {:error, term}
  def run(%{
        userid: %User{} = user,
        from_currency: from_currency,
        from_amount: from_amount,
        to_currency: to_currency,
        fetch_latest: fetch_latest
      }) do
    with {:ok, rates} <- Xchange.get_conversion_rates(fetch_latest: fetch_latest),
         {:ok, to_amount, rate} <-
           Xchange.convert(rates, to_currency: to_currency, amount: from_amount),
         {:ok, timestamp} <- parse_timestamp(rate.timestamp),
         {:ok, trx} <-
           Transaction.create(%{
             from_currency: from_currency,
             from_amount: from_amount,
             inserted_at: timestamp,
             user_id: user.id,
             conversion_rate: rate.conversion_rate,
             external_id: Ecto.UUID.generate()
           }) do
      {:ok,
       %{
         from_amount: from_amount,
         to_amount: to_amount,
         from_currency: from_currency,
         to_currency: to_currency,
         id: trx.external_id,
         user_id: user.external_id,
         timestamp: timestamp,
         conversion_rate: rate.conversion_rate
       }}
    end
  end

  defp parse_timestamp(unix) do
    with {:ok, datetime} <- DateTime.from_unix(unix) do
      {:ok, DateTime.to_naive(datetime)}
    end
  end
end
