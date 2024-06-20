defmodule RateWeb.TransactionControllerTest do
  use RateWeb.ConnCase, async: true

  import Mox

  alias Rate.Transactions.Transaction
  alias Rate.Xchange

  setup :verify_on_exit!

  @token_salt "super-secret"

  setup do
    user =
      Rate.Repo.insert!(%Rate.Accounts.User{external_id: "user123", email: "user@example.com"})

    Application.put_env(:rate, :authentication_token_salt, @token_salt)
    token = Phoenix.Token.sign(RateWeb.Endpoint, @token_salt, user.external_id)

    on_exit(fn ->
      Application.delete_env(:rate, :authentication_token_salt)
    end)

    conn =
      build_conn()
      |> assign(:current_user, user)
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

    {:ok, conn: conn, user: user, token: token}
  end

  describe "register/2" do
    test "registers a transaction successfully", %{conn: conn} do
      rates = [
        %Xchange.Rate{currency: "EUR", conversion_rate: 0.85, timestamp: 1_627_360_000},
        %Xchange.Rate{currency: "USD", conversion_rate: 1.0, timestamp: 1_627_360_000}
      ]

      ClientMock
      |> expect(:get_conversion_rates, fn _ -> {:ok, rates} end)

      params = %{
        "from_currency" => "USD",
        "from_amount" => 100.0,
        "to_currency" => "EUR",
        "fetch_latest" => true
      }

      conn = post(conn, "/api/v1/convert", params)
      assert conn.status == 201

      assert %{
               "conversion_rate" => 0.85,
               "from_amount" => 100.0,
               "from_currency" => "USD",
               "id" => _,
               "timestamp" => "2021-07-27T04:26:40",
               "to_amount" => 117.65,
               "to_currency" => "EUR",
               "user_id" => "user123"
             } = json_response(conn, 201)["data"]
    end

    test "returns an error when register params are invalid", %{conn: conn} do
      params = %{
        "from_currency" => 123,
        "from_amount" => "invalid",
        "to_currency" => nil
      }

      conn = post(conn, "/api/v1/convert", params)
      assert conn.status == 422
    end

    test "returns an error when transaction registration fails", %{conn: conn} do
      ClientMock
      |> expect(:get_conversion_rates, fn _ -> {:error, :conversion_failed} end)

      params = %{
        "from_currency" => "USD",
        "from_amount" => 100.0,
        "to_currency" => "EUR",
        "fetch_latest" => true
      }

      conn = post(conn, "/api/v1/convert", params)
      assert conn.status == 422
    end
  end

  describe "list/2" do
    test "lists transactions for the current user", %{conn: conn, user: user} do
      Rate.Repo.insert!(%Transaction{
        from_amount: 10000,
        from_currency: "USD",
        to_currency: "EUR",
        conversion_rate: 0.85,
        external_id: "trx1",
        user_id: user.id,
        inserted_at: ~N[2021-07-27 04:26:40]
      })

      conn = get(conn, "/api/v1/transactions")
      assert conn.status == 200

      assert json_response(conn, 200)["data"] == [
               %{
                 "from_amount" => 100.0,
                 "from_currency" => "USD",
                 "to_currency" => "EUR",
                 "conversion_rate" => 0.85,
                 "timestamp" => "2021-07-27T04:26:40",
                 "id" => "trx1",
                 "user_id" => "user123"
               }
             ]
    end
  end
end
