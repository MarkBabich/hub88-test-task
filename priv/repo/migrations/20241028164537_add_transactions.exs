defmodule Hub88Wallet.Repo.Migrations.AddTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :transaction_uuid, :uuid, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :currency, :string, null: false
      add :amount, :integer, null: false
      add :transaction_type, :string, null: false
      add :reference_transaction_uuid, :uuid
      add :is_closed, :boolean, null: false, default: false


      timestamps()
    end

    create unique_index(:transactions, [:transaction_uuid])
  end
end
