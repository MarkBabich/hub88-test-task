defmodule Hub88WalletWeb.TransactionController do
  use Hub88WalletWeb, :controller
  alias Hub88Wallet.Users.{User, Users}
  alias Hub88Wallet.Transactions.{Transaction, Transactions}
  alias Ecto.Multi
  alias Ecto.Repo
  alias Hub88Wallet.Repo


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
      {:ok, reference_transaction} <- validate_reference_transaction(reference_transaction_uuid) do

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

      create_transaction(user, transaction_data, conn)
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

      create_transaction(user, transaction_data, conn)
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

# Перевірка користувача
  defp validate_user(username) do
    case Users.get_user_by_name(username) do
      nil -> {:error, :invalid_user}
      user -> {:ok, user}
    end
  end

# Перевірка валюти
  defp validate_currency("EUR"), do: :ok
  defp validate_currency(_), do: {:error, :wrong_currency}

# Перевірка балансу користувача
  defp validate_balance(%{balance: balance}, amount) do
    if Decimal.compare(balance, Decimal.new(amount)) != :lt do
      :ok
    else
      {:error, :not_enough_money}
    end
  end

# Перевірка унікальності UUID транзакції
  defp validate_unique_transaction(transaction_uuid) do
    case Transactions.get_transaction_by_uuid(transaction_uuid) do
      nil -> :ok
      _transaction -> {:error, :duplicate_transaction}
    end
  end

  defp validate_reference_transaction(reference_transaction_uuid) do
    case Transactions.get_transaction_by_uuid(reference_transaction_uuid) do
      nil -> {:error, :reference_transaction_does_not_exist}
      transaction when transaction.is_closed == false -> {:ok, transaction}
      _closed_transaction -> {:error, :reference_transaction_closed}
    end
  end

# Створення транзакції
  defp create_transaction(user, transaction_data, conn) do
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
  end
end