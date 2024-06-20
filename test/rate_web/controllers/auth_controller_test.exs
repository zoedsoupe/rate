defmodule RateWeb.AuthControllerTest do
  use RateWeb.ConnCase

  alias Rate.Accounts.User

  @token_salt "super-secret"

  setup do
    Application.put_env(:rate, :authentication_token_salt, @token_salt)
    Application.put_env(:resend, Resend.Client, api_key: System.get_env("RESEND_KEY"))

    on_exit(fn ->
      Application.delete_env(:rate, :authentication_token_salt)
    end)

    :ok
  end

  describe "request_magic_link/2" do
    test "returns 202 Accepted when request_magic_link succeeds", %{conn: conn} do
      params = %{"email" => "user@example.com"}

      conn = post(conn, "/api/v1/login", params)
      assert conn.status == 202
      assert conn.resp_body == ""
    end

    test "returns 400 Bad Request when request_magic_link params are invalid", %{conn: conn} do
      params = %{"email" => 123}

      conn = post(conn, "/api/v1/login", params)
      assert conn.status == 422
    end
  end

  describe "login/2" do
    test "returns 201 Created when login succeeds", %{conn: conn} do
      user = Rate.Repo.insert!(%User{external_id: "user123", email: "example@example.com"})
      token = Phoenix.Token.sign(RateWeb.Endpoint, @token_salt, user.external_id)
      params = %{"token" => token}
      external_id = user.external_id

      conn = post(conn, "/api/v1", params)
      assert conn.status == 201

      assert %{"data" => %{"token" => ^token, "user_id" => ^external_id}} =
               json_response(conn, 201)
    end

    test "returns 401 when login params are invalid", %{conn: conn} do
      params = %{"token" => 123}

      conn = post(conn, "/api/v1", params)
      assert conn.status == 401
    end

    test "returns 401 Unauthorized when login fails", %{conn: conn} do
      params = %{"token" => "invalid_token"}

      conn = post(conn, "/api/v1", params)
      assert conn.status == 401
    end
  end
end
