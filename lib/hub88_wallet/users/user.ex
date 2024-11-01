defmodule Hub88Wallet.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :user, :string
    field :balance, :integer, default: 1000 * 100000
    field :currency, :string, default: "EUR"

    has_many :transactions, Hub88Wallet.Transactions.Transaction

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user, :balance, :currency])
    |> validate_required([:user, :balance, :currency])
    |> validate_length(:user, min: 3)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint(:user)
  end
end
