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
        when params: [external_id: Ecto.UUID.t()] | [email: String.t()]
  def find_by(external_id: id) do
    if user = Repo.get_by(User, external_id: id) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  def find_by(email: email) do
    if user = Repo.get_by(User, email: email) do
      {:ok, user}
    else
      {:error, :not_found}
    end
  end

  @spec get_or_create_user(email: String.t()) :: {:ok, User.t()} | {:error, atom}
  def get_or_create_user(email: email) do
    with {:error, :not_found} <- find_by(email: email) do
      create(%{email: email, external_id: Ecto.UUID.generate()})
    end
  end
end
