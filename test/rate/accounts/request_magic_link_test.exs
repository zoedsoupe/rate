defmodule Rate.Accounts.RequestMagicLinkTest do
  use Rate.DataCase

  alias Rate.Accounts.{RequestMagicLink, User}
  alias Rate.Repo

  @email "john@example.com"
  @token_salt "some-super-secret"

  setup do
    Application.put_env(:rate, :authentication_token_salt, @token_salt)
    Application.put_env(:resend, Resend.Client, api_key: System.get_env("RESEND_KEY"))

    on_exit(fn ->
      Application.delete_env(:rate, :authentication_token_salt)
    end)

    :ok
  end

  describe "run/1" do
    test "sends a magic link email to an existing user" do
      Repo.insert(%User{email: @email, external_id: Ecto.UUID.generate()})

      assert :ok == RequestMagicLink.run(email: @email)
    end

    test "creates a new user and sends a magic link email" do
      assert :ok == RequestMagicLink.run(email: @email)
    end
  end
end
