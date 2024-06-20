defmodule Rate.Transactions.Transaction do
  @moduledoc """
  Represents a currency conversion transaction and provides functions to manage transactions.

  This module defines a schema for currency conversion transactions and includes functions to create transactions and list them by user.

  ## Schema

  The `%Rate.Transactions.Transaction{}` schema has the following fields:

    * `:from_amount` - The amount in the source currency.
    * `:from_currency` - The source currency.
    * `:to_currency` - The target currency.
    * `:conversion_rate` - The conversion rate used for the transaction.
    * `:external_id` - A unique identifier for the transaction.
    * `:user_id` - The ID of the user who performed the transaction.
    * `:inserted_at` - The timestamp when the transaction was inserted.

  ## Functions

    * `changeset/2` - Creates a changeset for a transaction.
    * `create/1` - Creates a new transaction with the given parameters.
    * `list_by/1` - Lists all transactions performed by a specific user.
  """

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

  @doc """
  Creates a new transaction with the given parameters.

  This function creates a new transaction record in the database with the provided parameters and preloads the associated user.

  ## Parameters

    - `params`: A map containing the transaction parameters.

  ## Examples

      iex> params = %{from_amount: 100, from_currency: "USD", to_currency: "EUR", conversion_rate: 0.85, user_id: 1}
      iex> Rate.Transactions.Transaction.create(params)
      {:ok, %Transaction{...}}

  ## Returns

    - `{:ok, transaction}` if the transaction is successfully created.
    - `{:error, changeset}` if there is an error creating the transaction.

  """
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

  @doc """
  Lists all transactions performed by a specific user.

  This function retrieves all transactions from the database for the given user ID and preloads the associated user.

  ## Parameters

    - `user_id`: The ID of the user whose transactions are to be listed.

  ## Examples

      iex> Rate.Transactions.Transaction.list_by(user_id: 1)
      [%Transaction{...}, ...]

  ## Returns

    - A list of `%Transaction{}` structs representing the transactions performed by the user.

  """
  @spec list_by(user_id: integer) :: list(t)
  def list_by(user_id: user_id) do
    Repo.all(from t in Transaction, where: t.user_id == ^user_id, preload: [:user])
  end
end
