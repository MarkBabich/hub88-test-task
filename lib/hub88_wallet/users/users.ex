defmodule Hub88Wallet.Users.Users do
  alias Hub88Wallet.Repo
  alias Hub88Wallet.Users.User

  @default_balance Decimal.new("1000")
  @default_currency "EUR"

  def get_or_create_user_by_name(user_name) do
    case Repo.get_by(User, user: user_name) do
      nil ->
        %User{}
        |> User.changeset(%{user: user_name, balance: @default_balance, currency: @default_currency})
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  def get_user_by_name(user_name) do
    Repo.get_by(User, user: user_name)
  end
end
