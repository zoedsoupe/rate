defmodule Rate.Xchange.ExchangeRatesClient do
  @moduledoc false

  alias Rate.Xchange

  import Peri

  @behaviour Xchange.Behaviour

  @base_url "http://api.exchangeratesapi.io/latest"

  defp get_api_key do
    Application.get_env(:rate, Xchange)[:api_key]
  end

  @impl true
  def get_conversion_rates(opts \\ []) do
    fetch_latest? = Keyword.get(opts, :fetch_latest, false)

    if fetch_latest? do
      with {:ok, rates} <- fetch_latest_rates(make_request()) do
        Xchange.Cache.cache_conversion_rates(rates)
        {:ok, rates}
      end
    else
      case Xchange.Cache.get_conversion_rates() do
        [] -> get_conversion_rates(fetch_latest: true)
        rates -> {:ok, rates}
      end
    end
  end

  defp fetch_latest_rates(request) do
    case Req.get(request) do
      {:ok, %Req.Response{status: 200, body: body}} -> parse_rates_body(body)
      {:ok, %Req.Response{status: 404}} -> {:error, :client_not_found}
      {:ok, %Req.Response{status: 401}} -> {:error, :client_unauthenticated}
      {:error, exception} -> {:error, Exception.format(:error, exception)}
    end
  end

  defschema(:rate_t, %{
    timestamp: {:required, :integer},
    base: {:required, :string},
    rates: {:required, :map}
  })

  defp parse_rates_body(%{"success" => true} = params) do
    with {:ok, data} <- rate_t(params) do
      {:ok,
       for {currency, rate} <- data.rates do
         %Xchange.Rate{
           base: data.base,
           currency: currency,
           conversion_rate: rate,
           timestamp: data.timestamp
         }
       end}
    end
  end

  defp make_request do
    Req.new(base_url: @base_url, params: [base: "EUR", access_key: get_api_key()], json: true)
  end
end
