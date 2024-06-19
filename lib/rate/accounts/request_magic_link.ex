defmodule Rate.Accounts.RequestMagicLink do
  @moduledoc false

  alias Rate.Accounts.User

  @recipient Application.compile_env!(:rate, :own_email)

  defp get_token_salt do
    Application.get_env(:rate, :authentication_token_salt)
  end

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
    url = URI.append_query(uri, query)

    Resend.Emails.send(%{
      to: user.email,
      from: @recipient,
      subject: "Rate - Magic Link",
      text: "Please, confirm your login on this link: #{URI.to_string(url)}"
    })
  end
end
