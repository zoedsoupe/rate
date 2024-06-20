defmodule RateWeb.ErrorJSONTest do
  use RateWeb.ConnCase, async: true

  test "renders 404" do
    assert RateWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not found"},
             status: "error"
           }
  end

  test "renders 500" do
    assert RateWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}, status: "error"}
  end
end
