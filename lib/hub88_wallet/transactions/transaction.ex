defmodule Hub88Wallet.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :transaction_uuid, Ecto.UUID
    field :currency, :string
    field :amount, :decimal
    field :transaction_type, :string
    field :reference_transaction_uuid, Ecto.UUID
    field :is_closed, :boolean, default: false

    belongs_to :user, Hub88Wallet.Users.User
    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:transaction_uuid, :user_id, :currency, :amount, :transaction_type, :reference_transaction_uuid, :is_closed])
    |> validate_required([:transaction_uuid, :user_id, :currency, :amount, :transaction_type])
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:transaction_type, ["bet", "win"])
    |> unique_constraint(:transaction_uuid)
    |> foreign_key_constraint(:user_id)
  end
end
