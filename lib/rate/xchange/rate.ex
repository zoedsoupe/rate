defmodule Rate.Xchange.Rate do
  @moduledoc """
  Represents a currency conversion rate and provides utility functions for working with rates.

  This module defines a struct for a currency conversion rate and includes functions to find specific rates within a list.

  ## Struct

  The `%Rate.Xchange.Rate{}` struct has the following fields:

    * `:base` - The base currency for the conversion rate.
    * `:currency` - The target currency for the conversion rate.
    * `:conversion_rate` - The conversion rate from the base currency to the target currency.
    * `:timestamp` - The timestamp indicating when the conversion rate was retrieved.

  ## Functions

    * `find_by/2` - Finds a conversion rate by the target currency in a list of rates.
  """

  @type t :: %__MODULE__{
          base: String.t(),
          currency: String.t(),
          conversion_rate: float,
          timestamp: DateTime.t()
        }

  defstruct [:base, :currency, :conversion_rate, :timestamp]

  @doc """
  Finds a conversion rate by the target currency in a list of rates.

  This function searches through a list of `%Rate.Xchange.Rate{}` structs to find a rate with the specified target currency.

  ## Parameters

    - `rates`: A list of `%Rate.Xchange.Rate{}` structs.
    - `currency`: The target currency to find.

  ## Examples

      iex> rates = [%Rate.Xchange.Rate{currency: "USD", conversion_rate: 1.12}, %Rate.Xchange.Rate{currency: "EUR", conversion_rate: 0.89}]
      iex> Rate.Xchange.Rate.find_by(rates, currency: "USD")
      {:ok, %Rate.Xchange.Rate{currency: "USD", conversion_rate: 1.12}}

      iex> Rate.Xchange.Rate.find_by(rates, currency: "JPY")
      {:error, :not_found}

  ## Returns

    - `{:ok, rate}` if the rate with the specified currency is found.
    - `{:error, :not_found}` if the rate with the specified currency is not found.

  """
  @spec find_by(list(t), currency: String.t()) :: {:ok, t} | {:error, :not_found}
  def find_by(rates, currency: currency) do
    if rate = Enum.find(rates, &(&1.currency == currency)) do
      {:ok, rate}
    else
      {:error, :not_found}
    end
  end
end
