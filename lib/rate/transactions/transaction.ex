defmodule Rate.Transactions.Transaction do
  @moduledoc false

  use Rate, :model

  @type t :: %Transaction{
          id: integer,
          from_amount: integer,
          from_currency: String.t(),
          to_currency: String.t(),
          conversion_rate: float,
          external_id: Ecto.UUID.t(),
          user_id: integer
        }

  schema "transaction" do
    field :from_amount, :integer
    field :from_currency, :string
    field :to_currency, :string
    field :conversion_rate, :float
    field :external_id, :string

    belongs_to :user, Rate.Accounts.User

    timestamps()
  end

  @fields ~w(from_amount from_currency to_currency conversion_rate external_id user_id inserted_at)a

  def changeset(trx \\ %Transaction{}, %{} = params) do
    trx
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:user_id)
  end

  @spec create(params) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
        when params: %{
               from_amount: integer,
               from_currency: String.t(),
               to_currency: String.t(),
               conversion_rate: float,
               user_id: integer
             }
  def create(%{} = params) do
    %Transaction{}
    |> changeset(params)
    |> Repo.insert()
    |> then(fn
      {:ok, trx} -> {:ok, Repo.preload(trx, :user)}
      err -> err
    end)
  end

  def list_by(user_id: user_id) do
    Repo.all(from t in Transaction, where: t.user_id == ^user_id, preload: [:user])
  end
end
