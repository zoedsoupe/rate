defmodule Rate.Accounts.LoginTest do
  use Rate.DataCase

  alias Rate.Accounts.{Login, User}

  @invalid_token "invalid_token"
  @user_id "user123"
  @token_salt "some_salt"

  setup do
    Application.put_env(:rate, :authentication_token_salt, @token_salt)

    on_exit(fn ->
      Application.delete_env(:rate, :authentication_token_salt)
    end)

    {:ok, %{token: Phoenix.Token.sign(RateWeb.Endpoint, @token_salt, @user_id)}}
  end

  describe "run/1" do
    test "returns the user for a valid token", %{token: token} do
      user = Rate.Repo.insert!(%User{external_id: @user_id, email: "user@example.com"})
      assert {:ok, ^user} = Login.run(token: token)
    end

    test "returns an error for an invalid token" do
      assert {:error, :invalid} = Login.run(token: @invalid_token)
    end

    test "returns an error if the user is not found" do
      token = Phoenix.Token.sign(RateWeb.Endpoint, @token_salt, "user123")
      assert {:error, :not_found} = Login.run(token: token)
    end
  end
end
