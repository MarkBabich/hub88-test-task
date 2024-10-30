defmodule Hub88Wallet.Transactions.TransactionsTest do
  use Hub88Wallet.DataCase

  alias Hub88Wallet.Users.Users
  alias Hub88Wallet.Transactions.Transactions
  alias Hub88Wallet.Transactions.Transaction
  alias Hub88Wallet.Repo

  setup do
    {:ok, user} = Users.create_user("test_user")
    %{user: user}
  end

  describe "get_transaction_by_uuid/1" do
    test "returns nil if transaction does not exist" do
      non_existent_uuid = UUID.uuid4()
      assert Transactions.get_transaction_by_uuid(non_existent_uuid) == nil
    end

    test "returns the transaction if it exists", %{user: user} do
      transaction_uuid = UUID.uuid4()
      transaction_data = %{
        user_id: user.id,
        amount: Decimal.new("200.00"),
        transaction_uuid: transaction_uuid,
        currency: "EUR",
        transaction_type: "bet"
      }

      {:ok, _transaction} = Transactions.create_transaction(user, transaction_data)

      assert %Transaction{transaction_uuid: ^transaction_uuid} = Transactions.get_transaction_by_uuid(transaction_uuid)
    end
  end

  describe "create_transaction/2" do
    test "creates a bet transaction and updates user balance", %{user: user} do
      initial_balance = user.balance

      transaction_data = %{
        user_id: user.id,
        amount: Decimal.new("50.00"),
        transaction_uuid: UUID.uuid4(),
        currency: "EUR",
        transaction_type: "bet"
      }

      {:ok, _transaction} = Transactions.create_transaction(user, transaction_data)
      updated_user = Repo.get!(Hub88Wallet.Users.User, user.id)

      assert updated_user.balance == Decimal.sub(initial_balance, transaction_data.amount)
    end

    test "creates a win transaction and updates user balance", %{user: user} do
      bet_transaction_uuid = UUID.uuid4()
      initial_balance = user.balance

      bet_transaction_data = %{
        user_id: user.id,
        amount: Decimal.new("10.00"),
        transaction_uuid: bet_transaction_uuid,
        currency: "EUR",
        transaction_type: "bet"
      }

      {:ok, %{transaction: bet_transaction}} = Transactions.create_transaction(user, bet_transaction_data)

      transaction_data = %{
        user_id: user.id,
        amount: Decimal.new("50.00"),
        transaction_uuid: UUID.uuid4(),
        reference_transaction_uuid: bet_transaction_uuid,
        reference_transaction: bet_transaction,
        currency: "EUR",
        transaction_type: "win",
        is_closed: true
      }

      {:ok, %{user: updated_user}} = Transactions.create_transaction(user, transaction_data)

      assert updated_user.balance == Decimal.add(initial_balance, transaction_data.amount)
    end

    test "closes the corresponding bet transaction when a win transaction is created", %{user: user} do
      bet_uuid = UUID.uuid4()
      bet_data = %{
        user_id: user.id,
        amount: Decimal.new("50.00"),
        transaction_uuid: bet_uuid,
        currency: "EUR",
        transaction_type: "bet"
      }

      {:ok, %{transaction: bet_transaction}} = Transactions.create_transaction(user, bet_data)

      win_uuid = UUID.uuid4()
      win_data = %{
        user_id: user.id,
        amount: Decimal.new("100.00"),
        transaction_uuid: win_uuid,
        currency: "EUR",
        transaction_type: "win",
        reference_transaction_uuid: bet_transaction.transaction_uuid,
        reference_transaction: bet_transaction
      }

      {:ok, _win_transaction} = Transactions.create_transaction(user, win_data)

      closed_transaction = Repo.get!(Transaction, bet_transaction.id)
      assert closed_transaction.is_closed
    end
  end
end
