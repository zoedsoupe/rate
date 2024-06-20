defmodule Rate.XchangeTest do
  use ExUnit.Case, async: true

  import Mox

  alias Rate.Xchange
  alias Rate.Xchange

  setup :verify_on_exit!

  setup do
    Application.put_env(:rate, Rate.Xchange, client: ClientMock)
    :ok
  end

  describe "get_conversion_rates/1" do
    test "fetches conversion rates successfully" do
      rates = [%Xchange.Rate{currency: "USD", conversion_rate: 1.12}]

      ClientMock
      |> expect(:get_conversion_rates, fn _opts -> {:ok, rates} end)

      assert {:ok, ^rates} = Xchange.get_conversion_rates()
    end

    test "returns an error when fetching conversion rates fails" do
      ClientMock
      |> expect(:get_conversion_rates, fn _opts -> {:error, :failed} end)

      assert {:error, :failed} == Xchange.get_conversion_rates()
    end
  end

  describe "convert/2" do
    setup do
      rates = [
        %Xchange.Rate{currency: "USD", conversion_rate: 1.12},
        %Xchange.Rate{currency: "EUR", conversion_rate: 1.0},
        %Xchange.Rate{currency: "JPY", conversion_rate: 130.0}
      ]

      {:ok, rates: rates}
    end

    test "converts amount from one currency to another", %{rates: rates} do
      assert {:ok, 89.29, %Xchange.Rate{currency: "USD"}} =
               Xchange.convert(rates, to_currency: "USD", from_currency: "EUR", amount: 100.0)

      assert {:ok, +0.01, %Xchange.Rate{currency: "JPY"}} =
               Xchange.convert(rates, to_currency: "JPY", from_currency: "USD", amount: 1.0)
    end

    test "returns an error if target currency rate is not found", %{rates: rates} do
      assert {:error, :not_found} ==
               Xchange.convert(rates, to_currency: "GBP", from_currency: "USD", amount: 100)
    end

    test "returns an error if source currency rate is not found", %{rates: rates} do
      assert {:error, :not_found} ==
               Xchange.convert(rates, to_currency: "USD", from_currency: "GBP", amount: 100)
    end

    test "handles decimal rounding correctly", %{rates: rates} do
      assert {:ok, +0.0, %Xchange.Rate{currency: "JPY"}} =
               Xchange.convert(rates, to_currency: "JPY", from_currency: "USD", amount: 0.0001)
    end
  end
end
