defmodule Rate do
  @moduledoc """
  Rate keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias __MODULE__
      alias Rate.Repo
    end
  end

  defmacro __using__(type) when is_atom(type) do
    apply(__MODULE__, type, [])
  end
end
