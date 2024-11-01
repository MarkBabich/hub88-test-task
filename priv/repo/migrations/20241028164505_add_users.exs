defmodule Hub88Wallet.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user, :string, null: false
      add :balance, :integer, null: false, default: 1000 * 100000
      add :currency, :string, null: false, default: "EUR"

      timestamps()
    end
  end
end
