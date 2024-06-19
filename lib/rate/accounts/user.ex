defmodule Rate.Accounts.User do
  @moduledoc false

  use Rate, :model

  @type t :: %User{
          email: String.t(),
          external_id: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "user" do
    field :email, :string
    field :external_id, :string

    timestamps()
  end

  @required_fields ~w(email external_id)a

  def changeset(user \\ %User{}, %{} = params) do
    user
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  @spec create(params) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
        when params: %{email: String.t(), external_id: String.t()}
  def create(%{} = params) do
    %User{}
    |> changeset(params)
    |> Repo.insert()
  end

  @spec find_by(params) :: {:ok, User.t()} | {:error, :not_found}
        when params: [id: integer]
  def find_by(id: id) do
    if user = Repo.get(User, id) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end
end
