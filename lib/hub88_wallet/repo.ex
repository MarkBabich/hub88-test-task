defmodule Hub88Wallet.Repo do
  use Ecto.Repo,
    otp_app: :hub88_wallet,
    adapter: Ecto.Adapters.Postgres
end
