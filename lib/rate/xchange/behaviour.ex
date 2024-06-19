defmodule Rate.Xchange.Behaviour do
  @moduledoc false

  alias Rate.Xchange

  @callback get_conversion_rates :: {:ok, list(Xchange.Rate.t())} | {:error, atom}
end
