defmodule Rate.Xchange.ExchangeRatesClient do
  @moduledoc """
  A client module for fetching and caching currency conversion rates from an external API.

  This module implements the `Xchange.Behaviour` and provides functionality to fetch the latest conversion rates from an external API and cache them. It can retrieve cached rates or fetch new ones as needed.

  ## Functions

    * `get_conversion_rates/1` - Retrieves the conversion rates, either from cache or by fetching the latest rates from the API.
  """

  alias Rate.Xchange

  import Peri

  @behaviour Xchange.Behaviour

  @base_url "http://api.exchangeratesapi.io/latest"

  defp get_api_key do
    Application.get_env(:rate, Xchange)[:api_key]
  end

  @doc """
  Retrieves the conversion rates.

  This function checks if the latest rates should be fetched. If `fetch_latest` is true, it fetches the rates from the external API and caches them. Otherwise, it retrieves the rates from the cache.

  ## Parameters

    - `opts`: A list of options, including `:fetch_latest` to indicate whether to fetch the latest rates.

  ## Examples

      iex> Rate.Xchange.ExchangeRatesClient.get_conversion_rates()
      {:ok, [%Rate.Xchange.Rate{}]}

      iex> Rate.Xchange.ExchangeRatesClient.get_conversion_rates(fetch_latest: true)
      {:ok, [%Rate.Xchange.Rate{}]}

  ## Returns

    - `{:ok, rates}` if the conversion rates are successfully retrieved.
    - `{:error, reason}` if there is an error retrieving the rates.

  """
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
