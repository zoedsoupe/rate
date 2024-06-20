defmodule Rate.Xchange do
  @moduledoc """
  A facade module for handling currency exchange operations.

  This module provides functions to fetch conversion rates and convert amounts between currencies using these rates.

  ## Functions

    * `get_conversion_rates/1` - Fetches the latest conversion rates.
    * `convert/2` - Converts an amount from one currency to another using provided conversion rates.
  """

  alias Rate.Xchange

  defp get_client do
    Application.get_env(:rate, __MODULE__)[:client]
  end

  @doc """
  Fetches the latest conversion rates.

  This function uses the client module to fetch the latest conversion rates. It accepts an optional list of options that can be passed to the client module.

  ## Parameters

    - `opts`: A list of options to customize the fetching of conversion rates.

  ## Examples

      iex> Rate.Xchange.get_conversion_rates()
      {:ok, [%Rate.Xchange.Rate{}]}

      iex> Rate.Xchange.get_conversion_rates(base: "USD")
      {:ok, [%Rate.Xchange.Rate{}]}

  ## Returns

    - `{:ok, rates}` if the conversion rates are successfully fetched.
    - `{:error, reason}` if there is an error fetching the conversion rates.

  """
  def get_conversion_rates(opts \\ []) do
    get_client().get_conversion_rates(opts)
  end

  @doc """
  Converts an amount from one currency to another using provided conversion rates.

  This function takes a list of conversion rates and converts an amount from the source currency to the target currency.

  ## Parameters

    - `rates`: A list of `%Xchange.Rate{}` structs containing conversion rates.
    - `to_currency`: The target currency to convert the amount to.
    - `from_currency`: The source currency to convert the amount from.
    - `amount`: The amount to be converted.

  ## Examples

      iex> Rate.Xchange.convert(rates, to_currency: "USD", from_currency: "EUR", amount: 100)
      {:ok, 120.50, %Rate.Xchange.Rate{currency: "USD", conversion_rate: 1.205}}

      iex> Rate.Xchange.convert(rates, to_currency: "JPY", from_currency: "USD", amount: 50)
      {:ok, 5300.25, %Rate.Xchange.Rate{currency: "JPY", conversion_rate: 106.005}}

  ## Returns

    - `{:ok, converted_amount, rate}` if the conversion is successful, where `converted_amount` is the converted amount and `rate` is the rate used for conversion.
    - `{:error, reason}` if there is an error during the conversion process.

  """
  @spec convert(list(Xchange.Rate.t()),
          to_currency: String.t(),
          from_currency: String.t(),
          amount: integer
        ) ::
          {:ok, converted :: float, Xchange.Rate.t()} | {:error, term}
  def convert(rates, to_currency: to_currency, from_currency: from_currency, amount: amount) do
    with {:ok, rate} <- Xchange.Rate.find_by(rates, currency: to_currency),
         {:ok, source_rate} <- Xchange.Rate.find_by(rates, currency: from_currency) do
      amount = Decimal.from_float(amount)
      to_currency_rate = Decimal.from_float(rate.conversion_rate)
      from_currency_rate = Decimal.from_float(source_rate.conversion_rate)

      amount_in_eur = Decimal.div(amount, to_currency_rate)
      target_amount = Decimal.mult(amount_in_eur, from_currency_rate)
      target_amount_rounded = Decimal.round(target_amount, 2)

      {:ok, Decimal.to_float(target_amount_rounded), rate}
    end
  end
end
