defmodule Rate.Xchange.Cache do
  @moduledoc false

  use GenServer

  ## Public API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_conversion_rate(currency) do
    GenServer.call(__MODULE__, {:get_rate, currency})
  end

  def get_conversion_rates do
    GenServer.call(__MODULE__, :get_rates)
  end

  def cache_conversion_rates(rates) do
    GenServer.cast(__MODULE__, {:cache_rates, rates})
  end

  ## Server

  @impl true
  def init(:ok) do
    ref = :ets.new(:conversion_rates, [:set, :protected])
    {:ok, ref: ref}
  end

  @impl true
  def handle_call({:get_rate, currency}, _caller, ref: ref) do
    case :ets.lookup(ref, currency) do
      [{^currency, rate}] -> {:ok, {:ok, rate}, ref: ref}
      _ -> {:reply, {:error, :rate_not_found}, ref: ref}
    end
  end

  def handle_call(:get_rates, _caller, ref: ref) do
    {:reply, Enum.map(:ets.tab2list(ref), &elem(&1, 1)), ref: ref}
  end

  @impl true
  def handle_cast({:cahe_rates, rates}, ref: ref) do
    Task.start(__MODULE__, :save_rate_batch, [rates, ref: ref])
    {:noreply, ref: ref}
  end

  def save_rate_batch(rates, ref: ref) do
    for rate <- rates do
      :ets.insert(ref, {rate.currency, rate})
    end
  end
end
