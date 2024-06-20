defmodule Rate.Accounts.Login do
  @moduledoc """
  Provides functionality for logging in users using token-based authentication.

  This module handles the verification of login tokens and retrieval of user information based on the token.

  ## Functions

    * `run/1` - Verifies the provided token and returns the corresponding user if the token is valid.
  """

  alias Rate.Accounts.User

  defp get_token_salt do
    Application.get_env(:rate, :authentication_token_salt)
  end

  @doc """
  Verifies the provided token and retrieves the corresponding user.

  This function verifies the token and, if valid, fetches the user associated with the token's user ID.

  ## Parameters

    - `token`: The token to be verified.

  ## Examples

      iex> Rate.Accounts.Login.run(token: "some_valid_token")
      {:ok, %Rate.Accounts.User{}}

      iex> Rate.Accounts.Login.run(token: "invalid_token")
      {:error, :invalid}

  ## Returns

    - `{:ok, user}` if the token is valid and the user is found.
    - `{:error, reason}` if the token is invalid or the user is not found.

  """
  def run(token: token) do
    with {:ok, user_id} <- verify_login_token(token) do
      User.find_by(external_id: user_id)
    end
  end

  defp verify_login_token(token) do
    Phoenix.Token.verify(RateWeb.Endpoint, get_token_salt(), token, max_age: 86_400)
  end
end
