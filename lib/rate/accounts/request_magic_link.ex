defmodule Rate.Accounts.RequestMagicLink do
  @moduledoc """
  Handles the generation and sending of magic links for passwordless authentication.

  This module provides functionality to generate a login token, create a magic link, and send it to the user's email address for authentication.

  ## Functions

    * `run/1` - Initiates the process of sending a magic link to the user's email address.
  """

  alias Rate.Accounts.User

  @recipient Application.compile_env!(:rate, :own_email)

  defp get_token_salt do
    Application.get_env(:rate, :authentication_token_salt)
  end

  @doc """
  Initiates the process of sending a magic link to the user's email address.

  This function performs the following steps:

    1. Retrieves or creates a user based on the provided email.
    2. Generates a login token for the user.
    3. Sends an email containing the magic link with the token to the user.

  ## Parameters

    - `email`: The email address of the user.

  ## Examples

      iex> Rate.Accounts.RequestMagicLink.run(email: "user@example.com")
      :ok

      iex> Rate.Accounts.RequestMagicLink.run(email: "invalid@example.com")
      {:error, :user_creation_failed}

  ## Returns

    - `:ok` if the magic link email was sent successfully.
    - `{:error, reason}` if there was an error in the process.

  """
  @spec run(email: String.t()) :: :ok | {:error, atom}
  def run(email: email) do
    with {:ok, user} <- User.get_or_create_user(email: email),
         token = generate_login_token(user),
         {:ok, _email} <- send_magic_link_email(user, token) do
      :ok
    end
  end

  defp generate_login_token(%User{} = user) do
    Phoenix.Token.sign(RateWeb.Endpoint, get_token_salt(), user.external_id)
  end

  defp send_magic_link_email(%User{} = user, token) do
    query = URI.encode_query(%{token: token})
    uri = URI.new!(RateWeb.Endpoint.url())
    uri = URI.append_path(uri, "/api/v1")
    url = URI.append_query(uri, query)

    Resend.Emails.send(%{
      to: user.email,
      from: @recipient,
      subject: "Rate - Magic Link",
      text: "Please, confirm your login on this link: #{URI.to_string(url)}"
    })
  end
end
