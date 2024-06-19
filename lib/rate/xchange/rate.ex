defmodule Rate.Xchange.Rate do
  @moduledoc false

  @type t :: %__MODULE__{
          base: String.t(),
          currency: String.t(),
          conversion_rate: float,
          timestamp: DateTime.t()
        }

  defstruct [:base, :currency, :conversion_rate, :timestamp]

  @spec find_by(list(t), currency: String.t()) :: {:ok, t} | {:error, :not_found}
  def find_by(rates, currency: currency) do
    if rate = Enum.find(rates, &(&1.currency == currency)) do
      {:ok, rate}
    else
      {:error, :not_found}
    end
  end
end
