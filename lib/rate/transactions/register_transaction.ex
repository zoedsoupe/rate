defmodule Rate.Transactions.RegisterTransaction do
  @moduledoc """
  Handles the registration of currency conversion transactions.

  This module provides functionality to register transactions where a user converts an amount from one currency to another. It fetches the latest conversion rates, performs the conversion, and stores the transaction details.

  ## Functions

    * `run/1` - Registers a transaction with the provided parameters.
  """

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

  @doc """
  Registers a transaction with the provided parameters.

  This function performs the following steps:

    1. Fetches the latest conversion rates (if `fetch_latest` is true).
    2. Converts the specified amount from the source currency to the target currency.
    3. Parses the timestamp from the conversion rate.
    4. Creates a transaction record with the provided details and conversion results.

  ## Parameters

    - `params`: A map containing the following keys:
      - `user`: The user performing the transaction (a `%User{}` struct).
      - `from_currency`: The source currency.
      - `from_amount`: The amount to convert from the source currency.
      - `to_currency`: The target currency.
      - `fetch_latest`: (Optional) Whether to fetch the latest conversion rates.

  ## Examples

      iex> params = %{
      ...>   user: %User{id: 1, external_id: "abc123"},
      ...>   from_currency: "USD",
      ...>   from_amount: "100",
      ...>   to_currency: "EUR",
      ...>   fetch_latest: true
      ...> }
      iex> Rate.Transactions.RegisterTransaction.run(params)
      {:ok, %{
        from_amount: "100",
        to_amount: 85.0,
        from_currency: "USD",
        to_currency: "EUR",
        id: "some_uuid",
        user_id: "abc123",
        timestamp: ~N[2024-06-19 12:34:56],
        conversion_rate: 0.85
      }}

  ## Returns

    - `{:ok, transaction}` if the transaction is successfully registered.
    - `{:error, reason}` if there is an error during the transaction registration process.

  """
  @spec run(params_t) :: {:ok, Transaction.t()} | {:error, term}
  def run(
        %{
          user: %User{} = user,
          from_currency: from_currency,
          from_amount: from_amount,
          to_currency: to_currency
        } = params
      ) do
    fetch_latest = Map.get(params, :fetch_latest, false)

    with {:ok, rates} <- Xchange.get_conversion_rates(fetch_latest: fetch_latest),
         {:ok, to_amount, rate} <-
           Xchange.convert(rates,
             to_currency: to_currency,
             from_currency: from_currency,
             amount: from_amount
           ),
         {:ok, timestamp} <- parse_timestamp(rate.timestamp),
         {:ok, trx} <-
           Transaction.create(%{
             from_currency: from_currency,
             to_currency: to_currency,
             from_amount: Rate.Money.to_cents(from_amount),
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
