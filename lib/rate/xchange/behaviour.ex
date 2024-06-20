defmodule Rate.Xchange.Behaviour do
  @moduledoc """
  Defines the behaviour for modules that fetch currency conversion rates.

  This module specifies the callback functions that must be implemented by any module that adheres to this behaviour. It ensures that the implementing modules provide a function to retrieve conversion rates.

  ## Callbacks

    * `get_conversion_rates/1` - Retrieves the conversion rates, either from a cache or by fetching the latest rates from an external API.
  """

  alias Rate.Xchange

  @callback get_conversion_rates(opts) :: {:ok, list(Xchange.Rate.t())} | {:error, atom}
            when opts: [] | [fetch_latest?: true]
end
