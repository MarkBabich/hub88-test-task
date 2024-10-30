defmodule Hub88Wallet.Transactions.Transactions do
  alias Hub88Wallet.Repo
  alias Hub88Wallet.Transactions.Transaction
  alias Hub88Wallet.Users.User
  alias Ecto.Multi
  alias Ecto.Repo
  alias Hub88Wallet.Repo

  def get_transaction_by_uuid(transaction_uuid) do
    Repo.get_by(Transaction, transaction_uuid: transaction_uuid)
  end

  def create_transaction(user, transaction_data) do
    new_balance =
      case transaction_data.transaction_type do
        "bet" -> Decimal.sub(user.balance, transaction_data.amount)
        "win" -> Decimal.add(user.balance, transaction_data.amount)
      end

    multi =
      Multi.new()
      |> Multi.insert(:transaction, Transaction.changeset(%Transaction{}, transaction_data))
      |> Multi.update(:user, User.changeset(user, %{balance: new_balance}))

    multi =
      case transaction_data.transaction_type do
        "win" -> multi |> Multi.update(:bet_transaction,  Transaction.changeset(transaction_data.reference_transaction, %{is_closed: true}))
        "bet" -> multi
      end

    multi
      |> Repo.transaction()
  end
end
