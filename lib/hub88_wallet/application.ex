defmodule Hub88Wallet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hub88WalletWeb.Telemetry,
      Hub88Wallet.Repo,
      {DNSCluster, query: Application.get_env(:hub88_wallet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hub88Wallet.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Hub88Wallet.Finch},
      # Start a worker by calling: Hub88Wallet.Worker.start_link(arg)
      # {Hub88Wallet.Worker, arg},
      # Start to serve requests, typically the last entry
      Hub88WalletWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hub88Wallet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Hub88WalletWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
