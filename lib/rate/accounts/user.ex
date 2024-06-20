defmodule Rate.Accounts.User do
  @moduledoc """
  Represents a user and provides functions to manage user records.

  This module defines a schema for users and includes functions to create users, find users by email or external ID, and get or create a user based on email.

  ## Schema

  The `%Rate.Accounts.User{}` schema has the following fields:

    * `:email` - The email address of the user.
    * `:external_id` - A unique identifier for the user.
    * `:inserted_at` - The timestamp when the user was inserted.
    * `:updated_at` - The timestamp when the user was last updated.

  ## Functions

    * `changeset/2` - Creates a changeset for a user.
    * `create/1` - Creates a new user with the given parameters.
    * `find_by/1` - Finds a user by email or external ID.
    * `get_or_create_user/1` - Retrieves a user by email or creates a new one if not found.
  """

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

  @doc """
  Creates a new user with the given parameters.

  This function creates a new user record in the database with the provided parameters.

  ## Parameters

    - `params`: A map containing the user parameters.

  ## Examples

      iex> params = %{email: "user@example.com", external_id: "abc123"}
      iex> Rate.Accounts.User.create(params)
      {:ok, %User{...}}

  ## Returns

    - `{:ok, user}` if the user is successfully created.
    - `{:error, changeset}` if there is an error creating the user.

  """
  @spec create(params) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
        when params: %{email: String.t(), external_id: String.t()}
  def create(%{} = params) do
    %User{}
    |> changeset(params)
    |> Repo.insert()
  end

  @doc """
  Finds a user by email or external ID.

  This function searches the database for a user with the specified email or external ID.

  ## Parameters

    - `params`: A keyword list containing either `:email` or `:external_id`.

  ## Examples

      iex> Rate.Accounts.User.find_by(external_id: "abc123")
      {:ok, %User{...}}

      iex> Rate.Accounts.User.find_by(email: "user@example.com")
      {:ok, %User{...}}

      iex> Rate.Accounts.User.find_by(email: "nonexistent@example.com")
      {:error, :not_found}

  ## Returns

    - `{:ok, user}` if the user is found.
    - `{:error, :not_found}` if the user is not found.

  """
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

  @doc """
  Retrieves a user by email or creates a new one if not found.

  This function tries to find a user by email. If the user does not exist, it creates a new user with the given email and a generated external ID.

  ## Parameters

    - `email`: The email address of the user.

  ## Examples

      iex> Rate.Accounts.User.get_or_create_user(email: "user@example.com")
      {:ok, %User{...}}

      iex> Rate.Accounts.User.get_or_create_user(email: "newuser@example.com")
      {:ok, %User{...}}

  ## Returns

    - `{:ok, user}` if the user is found or successfully created.
    - `{:error, reason}` if there is an error during the process.

  """
  @spec get_or_create_user(email: String.t()) :: {:ok, User.t()} | {:error, atom}
  def get_or_create_user(email: email) do
    with {:error, :not_found} <- find_by(email: email) do
      create(%{email: email, external_id: Ecto.UUID.generate()})
    end
  end
end
