defmodule RateWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  def render("500.json", _assigns) do
    %{status: "error", errors: %{detail: "Internal Server Error"}}
  end

  def render("404.json", _assigns) do
    %{status: "error", errors: %{detail: "Not found"}}
  end

  def render("422.json", %{error: error}) do
    %{status: "error", errors: %{detail: inspect(error)}}
  end

  def render(template, _assigns) do
    %{
      status: "error",
      errors: %{detail: Phoenix.Controller.status_message_from_template(template)}
    }
  end
end
