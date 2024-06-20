defmodule Rate.Xchange.Cache do
  @moduledoc """
  A GenServer module for caching and retrieving currency conversion rates.

  This module provides a caching mechanism for currency conversion rates using ETS. It supports storing conversion rates, retrieving a specific conversion rate, and fetching all cached rates.

  ## Public API

    * `start_link/1` - Starts the GenServer process.
    * `get_conversion_rate/1` - Retrieves the conversion rate for a specific currency.
    * `get_conversion_rates/0` - Retrieves all cached conversion rates.
    * `cache_conversion_rates/1` - Caches a list of conversion rates.
  """

  use GenServer

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Retrieves the conversion rate for a specific currency.

  This function fetches the conversion rate for the given currency from the cache.

  ## Parameters

    - `currency`: The currency for which the conversion rate is requested.

  ## Examples

      iex> Rate.Xchange.Cache.get_conversion_rate("USD")
      {:ok, %Rate.Xchange.Rate{currency: "USD", conversion_rate: 1.12}}

      iex> Rate.Xchange.Cache.get_conversion_rate("NON_EXISTENT")
      {:error, :rate_not_found}

  ## Returns

    - `{:ok, rate}` if the conversion rate is found.
    - `{:error, :rate_not_found}` if the conversion rate is not found in the cache.

  """
  def get_conversion_rate(currency) do
    GenServer.call(__MODULE__, {:get_rate, currency})
  end

  @doc """
  Retrieves all cached conversion rates.

  This function fetches all conversion rates stored in the cache.

  ## Examples

      iex> Rate.Xchange.Cache.get_conversion_rates()
      [%Rate.Xchange.Rate{currency: "USD", conversion_rate: 1.12},
       %Rate.Xchange.Rate{currency: "EUR", conversion_rate: 0.89}]

  ## Returns

    - A list of `%Rate.Xchange.Rate{}` structs representing the cached conversion rates.

  """
  def get_conversion_rates do
    GenServer.call(__MODULE__, :get_rates)
  end

  @doc """
  Caches a list of conversion rates.

  This function stores the provided list of conversion rates in the cache.

  ## Parameters

    - `rates`: A list of `%Rate.Xchange.Rate{}` structs to be cached.

  ## Examples

      iex> rates = [%Rate.Xchange.Rate{currency: "USD", conversion_rate: 1.12},
      ...>           %Rate.Xchange.Rate{currency: "EUR", conversion_rate: 0.89}]
      iex> Rate.Xchange.Cache.cache_conversion_rates(rates)
      :ok

  ## Returns

    - `:ok` after the rates are successfully cached.

  """
  def cache_conversion_rates(rates) do
    GenServer.cast(__MODULE__, {:cache_rates, rates})
  end

  ## Server

  @impl true
  def init(:ok) do
    ref = :ets.new(:conversion_rates, [:set])
    {:ok, ref: ref}
  end

  @impl true
  def handle_call({:get_rate, currency}, _caller, ref: ref) do
    case :ets.lookup(ref, currency) do
      [{^currency, rate}] -> {:reply, {:ok, rate}, ref: ref}
      _ -> {:reply, {:error, :rate_not_found}, ref: ref}
    end
  end

  def handle_call(:get_rates, _caller, ref: ref) do
    {:reply, Enum.map(:ets.tab2list(ref), &elem(&1, 1)), ref: ref}
  end

  @impl true
  def handle_info({:"ETS-TRANSFER", ref, _owner, _data}, _state) do
    {:noreply, ref: ref}
  end

  @impl true
  def handle_cast({:cache_rates, rates}, ref: ref) do
    {:ok, pid} = Task.start(__MODULE__, :save_rate_batch, [rates, [ref: ref]])
    :ets.give_away(ref, pid, nil)
    {:noreply, ref: ref}
  end

  def save_rate_batch(rates, ref: ref) do
    for rate <- rates do
      :ets.insert(ref, {rate.currency, rate})
    end

    pid = Process.whereis(__MODULE__)
    :ets.give_away(ref, pid, nil)
  end
end
