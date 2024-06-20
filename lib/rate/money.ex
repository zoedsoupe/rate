defmodule Rate.Money do
  @moduledoc """
  Provides utility functions for handling money conversions.

  This module includes functions to convert amounts between float/decimal representations and integer representations in cents.

  ## Functions

    * `to_cents/1` - Converts a float or decimal amount to an integer amount in cents.
    * `to_float/1` - Converts an integer amount in cents to a float representation.
  """

  @doc """
  Converts a decimal or float amount to an integer amount in cents.

  This function takes a decimal or float amount and converts it to its integer representation in cents.

  ## Parameters

    - `amount`: The amount to be converted, which can be a `Decimal` struct or a float.

  ## Examples

      iex> Rate.Money.to_cents(123.45)
      12345

      iex> Rate.Money.to_cents(Decimal.new("123.45"))
      12345

  ## Returns

    - An integer representing the amount in cents.

  """
  @spec to_cents(float | Decimal.t()) :: integer
  def to_cents(%Decimal{} = dec) do
    dec
    |> Decimal.to_float()
    |> to_cents()
  end

  def to_cents(float_amount) when is_float(float_amount) do
    round(float_amount * 100)
  end

  @doc """
  Converts an integer amount in cents to a float representation.

  This function takes an integer amount representing cents and converts it to a float representation.

  ## Parameters

    - `cents`: The integer amount in cents to be converted.

  ## Examples

      iex> Rate.Money.to_float(12345)
      123.45

  ## Returns

    - A float representing the amount.

  """
  @spec to_float(integer | float) :: float
  def to_float(cents) do
    cents / 100
  end
end
