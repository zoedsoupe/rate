defmodule Rate.Accounts.RequestMagicLink do
  @moduledoc false

  alias Rate.Accounts.User
  alias Rate.Repo

  @token_salt Application.compile_env!(:rate, :authentication_token_salt)
  @recipient Application.compile_env!(:rate, :own_email)

  @spec run(email: String.t()) :: :ok | {:error, atom}
  def run(email: email) do
    with {:ok, user} <- User.get_or_create_user(email: email),
         token = generate_login_token(user),
         {:ok, _email} <- send_magic_link_email(user, token) do
      :ok
    end
  end

  defp generate_login_token(%User{} = user) do
    Phoenix.Token.sign(RateWeb.Endpoint, @token_salt, user.id)
  end

  defp send_magic_link_email(%User{} = user, token) do
    query = URI.encode_query(%{token: token})
    uri = URI.new!(KontaWeb.Endpoint.url())
    url = URI.append_query(uri, query)

    Resend.Emails.send(%{
      to: user.email,
      from: @recipient,
      subject: "Rate - Magic Link",
      text: "Please, confirm your login on this link: #{URI.to_string(url)}"
    })
  end
end
