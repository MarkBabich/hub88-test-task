defmodule Hub88WalletWeb.TransactionController do
  use Hub88WalletWeb, :controller
  alias Hub88Wallet.Users.Users
  alias Hub88Wallet.Transactions.Transactions

  def create_win(conn, %{
    "user" => username,
    "transaction_uuid" => transaction_uuid,
    "reference_transaction_uuid" => reference_transaction_uuid,
    "amount" => amount,
    "currency" => currency
  }) do
  with {:ok, user} <- validate_user(username),
      :ok <- validate_currency(currency),
      :ok <- validate_unique_transaction(transaction_uuid),
      {:ok, reference_transaction} <- validate_reference_transaction(reference_transaction_uuid, user.id) do

      transaction_data = %{
        user_id: user.id,
        amount: Decimal.new(amount),
        currency: currency,
        transaction_uuid: transaction_uuid,
        reference_transaction_uuid: reference_transaction_uuid,
        transaction_type: "win",
        is_closed: true,
        reference_transaction: reference_transaction
      }

      Transactions.create_transaction(user, transaction_data)
        |> case do
          {:ok, %{user: updated_user}} ->
            json(conn, %{
              status: "RS_OK",
              user: updated_user.user,
              balance: Decimal.to_string(updated_user.balance)
            })

          {:error, _operation, _reason, _changes} ->
            json(conn, %{status: "RS_UNKNOWN_ERROR"})
        end
    else
      {:error, :invalid_user} ->
        json(conn, %{status: "RS_ERROR_INVALID_USER"})

      {:error, :wrong_currency} ->
        json(conn, %{status: "RS_ERROR_WRONG_CURRENCY"})

      {:error, :reference_transaction_does_not_exist} ->
        json(conn, %{status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"})

      {:error, :reference_transaction_closed} ->
        json(conn, %{status: "RS_ERROR_TRANSACTION_CLOSED"})

      {:error, :duplicate_transaction} ->
        json(conn, %{status: "RS_ERROR_DUPLICATE_TRANSACTION"})

      _ ->
        json(conn, %{status: "RS_UNKNOWN_ERROR"})
    end
  end

  def create_win(conn, _params) do
    json(conn, %{status: "RS_ERROR_WRONG_SYNTAX"})
  end

  def create_bet(conn, %{
    "user" => username,
    "transaction_uuid" => transaction_uuid,
    "amount" => amount,
    "currency" => currency
  }) do
  with {:ok, user} <- validate_user(username),
      :ok <- validate_currency(currency),
      :ok <- validate_balance(user, amount),
      :ok <- validate_unique_transaction(transaction_uuid) do

      transaction_data = %{
        user_id: user.id,
        amount: Decimal.new(amount),
        currency: currency,
        transaction_uuid: transaction_uuid,
        transaction_type: "bet"
      }

      Transactions.create_transaction(user, transaction_data)
        |> case do
          {:ok, %{user: updated_user}} ->
            json(conn, %{
              status: "RS_OK",
              user: updated_user.user,
              balance: Decimal.to_string(updated_user.balance)
            })

          {:error, _operation, _reason, _changes} ->
            json(conn, %{status: "RS_UNKNOWN_ERROR"})
        end
    else
      {:error, :invalid_user} ->
        json(conn, %{status: "RS_ERROR_INVALID_USER"})

      {:error, :wrong_currency} ->
        json(conn, %{status: "RS_ERROR_WRONG_CURRENCY"})

      {:error, :not_enough_money} ->
        json(conn, %{status: "RS_ERROR_NOT_ENOUGH_MONEY"})

      {:error, :duplicate_transaction} ->
        json(conn, %{status: "RS_ERROR_DUPLICATE_TRANSACTION"})

      _ ->
        json(conn, %{status: "RS_UNKNOWN_ERROR"})
    end
  end

  def create_bet(conn, _params) do
    json(conn, %{status: "RS_ERROR_WRONG_SYNTAX"})
  end

  defp validate_user(username) do
    case Users.get_user_by_name(username) do
      nil -> {:error, :invalid_user}
      user -> {:ok, user}
    end
  end

  defp validate_currency("EUR"), do: :ok
  defp validate_currency(_), do: {:error, :wrong_currency}

  defp validate_balance(%{balance: balance}, amount) do
    if Decimal.compare(balance, Decimal.new(amount)) != :lt do
      :ok
    else
      {:error, :not_enough_money}
    end
  end

  defp validate_unique_transaction(transaction_uuid) do
    case Transactions.get_transaction_by_uuid(transaction_uuid) do
      nil -> :ok
      _transaction -> {:error, :duplicate_transaction}
    end
  end

  defp validate_reference_transaction(reference_transaction_uuid, user_id) do
    case Transactions.get_transaction_by_uuid(reference_transaction_uuid) do
      nil -> {:error, :reference_transaction_does_not_exist}
      transaction when transaction.user_id !== user_id -> {:error, :reference_transaction_does_not_exist}
      transaction when transaction.is_closed == false -> {:ok, transaction}
      _closed_transaction -> {:error, :reference_transaction_closed}
    end
  end
end
