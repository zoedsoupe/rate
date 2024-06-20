defmodule Rate.Money do
  @moduledoc false

  @spec to_cents(float | Decimal.t()) :: integer
  def to_cents(%Decimal{} = dec) do
    dec
    |> Decimal.to_float()
    |> to_cents()
  end

  def to_cents(float_amount) when is_float(float_amount) do
    round(float_amount * 100)
  end

  @spec to_float(integer | float) :: float
  def to_float(cents) do
    cents / 100
  end
end
