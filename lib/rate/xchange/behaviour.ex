defmodule Rate.Xchange.Behaviour do
  @moduledoc false

  alias Rate.Xchange

  @callback get_conversion_rates(opts) :: {:ok, list(Xchange.Rate.t())} | {:error, atom}
            when opts: [] | [fetch_latest?: true]
end
