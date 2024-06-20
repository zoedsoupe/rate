defmodule Rate.Transactions.RegisterTransactionTest do
  use Rate.DataCase, async: true

  import Mox

  alias Rate.Transactions.RegisterTransaction
  alias Rate.Accounts.User
  alias Rate.Xchange

  setup :verify_on_exit!

  setup do
    Application.put_env(:rate, Rate.Xchange, client: ClientMock)
    :ok
  end

  describe "run/1" do
    setup do
      user = Rate.Repo.insert!(%User{external_id: "user123", email: "user@example.com"})
      {:ok, user: user}
    end

    test "registers a transaction successfully", %{user: user} do
      rates = [
        %Xchange.Rate{currency: "EUR", conversion_rate: 0.85, timestamp: 1_627_360_000},
        %Xchange.Rate{currency: "USD", conversion_rate: 1.0, timestamp: 1_627_360_000}
      ]

      ClientMock
      |> expect(:get_conversion_rates, fn _ -> {:ok, rates} end)

      params = %{
        user: user,
        from_currency: "USD",
        from_amount: 100.0,
        to_currency: "EUR",
        fetch_latest: true
      }

      result = RegisterTransaction.run(params)

      assert {
               :ok,
               %{
                 conversion_rate: 0.85,
                 from_amount: 100.0,
                 from_currency: "USD",
                 timestamp: ~N[2021-07-27 04:26:40],
                 to_amount: 117.65,
                 to_currency: "EUR",
                 user_id: "user123"
               }
             } = result
    end

    test "returns an error if fetching conversion rates fails" do
      rates = []

      ClientMock
      |> expect(:get_conversion_rates, fn _ -> {:ok, rates} end)

      params = %{
        user: %User{id: 1},
        from_currency: "USD",
        from_amount: 100.0,
        to_currency: "EUR",
        fetch_latest: true
      }

      assert {:error, :not_found} == RegisterTransaction.run(params)
    end

    test "returns an error if conversion fails" do
      ClientMock
      |> expect(:get_conversion_rates, fn _ -> {:error, :conversion_failed} end)

      params = %{
        user: %User{id: 1},
        from_currency: "USD",
        from_amount: 100.0,
        to_currency: "EUR",
        fetch_latest: true
      }

      assert {:error, :conversion_failed} == RegisterTransaction.run(params)
    end

    test "returns an error if creating transaction fails" do
      rates = [
        %Xchange.Rate{currency: "EUR", conversion_rate: 0.85, timestamp: 1_627_360_000},
        %Xchange.Rate{currency: "USD", conversion_rate: 1.0, timestamp: 1_627_360_000}
      ]

      ClientMock
      |> expect(:get_conversion_rates, fn _ -> {:ok, rates} end)

      params = %{
        user: %User{id: 0},
        from_currency: "USD",
        from_amount: 100.0,
        to_currency: "EUR",
        fetch_latest: true
      }

      assert {:error, changeset} = RegisterTransaction.run(params)
      refute changeset.valid?
    end
  end
end
