defmodule Rate.Xchange do
  @moduledoc false

  alias Rate.Xchange

  defp get_client do
    Application.get_env(:rate, __MODULE__)[:client]
  end

  def get_conversion_rates(opts \\ []) do
    get_client().get_conversion_rates(opts)
  end

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
