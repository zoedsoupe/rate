defmodule Rate do
  @moduledoc """
  Rate keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def get_env do
    Application.get_env(:rate, :env)
  end

  def model do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query
      alias __MODULE__
      alias Rate.Repo
    end
  end

  defmacro __using__(type) when is_atom(type) do
    apply(__MODULE__, type, [])
  end
end
