defmodule Rate.Xchange do
  @moduledoc false

  alias Rate.Xchange

  defp get_client do
    Application.get_env(:rate, __MODULE__)[:client]
  end

  def get_conversion_rates(opts \\ []) do
    get_client().get_conversion_rates(opts)
  end

  @spec convert(list(Xchange.Rate.t()), to_currency: String.t(), amount: integer) ::
          {:ok, converted :: float, Xchange.Rate.t()} | {:error, term}
  def convert(rates, to_currency: to_currency, amount: amount) when is_integer(amount) do
    with {:ok, rate} <- Xchange.Rate.find_by(rates, currency: to_currency) do
      cents_rate = Rate.Money.to_cents(rate.conversion_rate)

      {:ok, Rate.Money.to_float(amount * cents_rate), rate}
    end
  end
end
