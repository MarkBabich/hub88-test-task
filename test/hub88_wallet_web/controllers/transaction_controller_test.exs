defmodule Hub88WalletWeb.TransactionControllerTest do
  use Hub88WalletWeb.ConnCase
  @endpoint Hub88WalletWeb.Endpoint

  alias Hub88Wallet.Users.{Users}
  alias Hub88Wallet.Transactions.{Transactions}

  setup do
    {:ok, user} = Users.create_user("test_user")
    %{user: user}
  end

  describe "create_bet" do
    test "successful create_bet", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid,
        "amount" => 20000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/bet", params)

      assert json_response(conn, 200) == %{
        "status" => "RS_OK",
        "user" => user.user,
        "balance" => 80000000
      }
    end

    test "create_bet with insufficient balance", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid,
        "amount" => 200000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/bet", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_NOT_ENOUGH_MONEY"}
    end

    test "create_bet with invalid currency", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid,
        "amount" => 10000000,
        "currency" => "USD"
      }

      conn = post(conn, ~p"/transaction/bet", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_WRONG_CURRENCY"}
    end

    test "create_bet with duplicate transaction UUID", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()

      transaction_data = %{
        user_id: user.id,
        amount: 20000000,
        transaction_uuid: transaction_uuid,
        currency: "EUR",
        transaction_type: "bet"
      }

      Transactions.create_transaction(user, transaction_data)

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid,
        "amount" => 10000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/bet", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_DUPLICATE_TRANSACTION"}
    end

    test "create_bet with incorrect syntax", %{conn: conn} do
      params = %{
        "user" => "test_user"
      }

      conn = post(conn, ~p"/transaction/bet", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_WRONG_SYNTAX"}
    end
  end

  describe "create_win" do
    test "successful create_win", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()
      transaction_uuid_2 = UUID.uuid4()

      transaction_data = %{
        user_id: user.id,
        amount: 20000000,
        transaction_uuid: transaction_uuid,
        currency: "EUR",
        transaction_type: "bet"
      }

      Transactions.create_transaction(user, transaction_data)

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid_2,
        "reference_transaction_uuid" => transaction_uuid,
        "amount" => 30000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/win", params)

      assert json_response(conn, 200) == %{
        "status" => "RS_OK",
        "user" => user.user,
        "balance" => 110000000
      }
    end

    test "create_win with non-existent reference transaction", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()
      non_existent_transaction_uuid = UUID.uuid4()

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid,
        "reference_transaction_uuid" => non_existent_transaction_uuid,
        "amount" => 30000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/win", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}
    end

    test "create_win with closed reference transaction", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()
      transaction_uuid_2 = UUID.uuid4()

      transaction_data = %{
        user_id: user.id,
        amount: 20000000,
        transaction_uuid: transaction_uuid,
        currency: "EUR",
        transaction_type: "bet",
        is_closed: true
      }

      Transactions.create_transaction(user, transaction_data)

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid_2,
        "reference_transaction_uuid" => transaction_uuid,
        "amount" => 30000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/win", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_TRANSACTION_CLOSED"}
    end

    test "create_win with reference transaction owned by another user", %{conn: conn, user: user} do
      transaction_uuid = UUID.uuid4()
      transaction_uuid_2 = UUID.uuid4()

      {:ok, another_user} = Users.create_user("another_user")

      transaction_data = %{
        user_id: another_user.id,
        amount: 20000000,
        transaction_uuid: transaction_uuid,
        currency: "EUR",
        transaction_type: "bet",
      }

      {:ok, %{transaction: another_bet}} = Transactions.create_transaction(another_user, transaction_data)

      params = %{
        "user" => user.user,
        "transaction_uuid" => transaction_uuid_2,
        "reference_transaction_uuid" => another_bet.transaction_uuid,
        "amount" => 30000000,
        "currency" => "EUR"
      }

      conn = post(conn, ~p"/transaction/win", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}
    end

    test "create_win with incorrect syntax", %{conn: conn} do
      params = %{
        "user" => "test_user"
      }

      conn = post(conn, ~p"/transaction/win", params)

      assert json_response(conn, 200) == %{"status" => "RS_ERROR_WRONG_SYNTAX"}
    end
  end
end
