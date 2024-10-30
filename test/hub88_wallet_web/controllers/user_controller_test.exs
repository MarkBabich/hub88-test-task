defmodule Hub88WalletWeb.UserControllerTest do
  use Hub88WalletWeb.ConnCase
  alias Hub88Wallet.Users.{Users}

  setup do
    {:ok, user} = Users.create_user("test_user")
    %{user: user}
  end

  describe "balance" do
    test "successful balance retrieval", %{conn: conn, user: user} do
      params = %{"user" => user.user}

      conn = post(conn, ~p"/user/balance", params)

      assert json_response(conn, 200) == %{
        "status" => "RS_OK",
        "user" => user.user,
        "balance" => Decimal.to_string(user.balance),
        "currency" => user.currency
      }
    end

    test "balance retrieval for non-existent user", %{conn: conn} do
      params = %{"user" => "non_existent_user"}

      conn = post(conn, ~p"/user/balance", params)

      assert json_response(conn, 200) == %{"status" => "RS_OK", "user" => "non_existent_user", "balance" => "1000.00", "currency" => "EUR"}
    end

    test "balance retrieval with incorrect syntax", %{conn: conn} do
      params = %{}

      conn = post(conn, ~p"/user/balance", params)

      assert json_response(conn, 400) == %{"status" => "RS_ERROR_WRONG_SYNTAX"}
    end

    test "balance retrieval with non-binary user name", %{conn: conn} do
      params = %{"user" => 12345}

      conn = post(conn, ~p"/user/balance", params)

      assert json_response(conn, 400) == %{"status" => "RS_ERROR_WRONG_SYNTAX"}
    end
  end
end
