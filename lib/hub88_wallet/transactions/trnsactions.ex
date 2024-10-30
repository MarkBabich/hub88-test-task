defmodule Hub88Wallet.Transactions.Transactions do
  alias Hub88Wallet.Repo
  alias Hub88Wallet.Transactions.Transaction

  def get_transaction_by_uuid(transaction_uuid) do
    Repo.get_by(Transaction, transaction_uuid: transaction_uuid)
  end

  
end
