defmodule Hub88WalletWeb.UserController do
  use Hub88WalletWeb, :controller
  alias Hub88Wallet.Users.Users

  def balance(conn, %{"user" => user_name}) when is_binary(user_name) do
    case Users.get_or_create_user_by_name(user_name) do
      {:ok, user} ->
        json(conn, %{user: user.user, status: "RS_OK", balance: user.balance, currency: user.currency})

      {:error, _changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "RS_ERROR_UNKNOWN"})
    end
  end

  def balance(connn, _) do
    connn
      |> put_status(:bad_request)
      |> json(%{status: "RS_ERROR_WRONG_SYNTAX"})
  end
end
