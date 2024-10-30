defmodule Hub88WalletWeb.ErrorJSONTest do
  use Hub88WalletWeb.ConnCase, async: true

  test "renders 404" do
    assert Hub88WalletWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Hub88WalletWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
