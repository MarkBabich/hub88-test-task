defmodule Hub88Wallet.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user, :string, null: false
      add :balance, :decimal, null: false, precision: 10,  scale: 2, default: 1000.00
      add :currency, :string, null: false, default: "EUR"

      timestamps()
    end
  end
end
