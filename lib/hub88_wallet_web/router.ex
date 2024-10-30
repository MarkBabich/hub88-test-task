defmodule Hub88WalletWeb.Router do
  use Hub88WalletWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Hub88WalletWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", Hub88WalletWeb do
  #   pipe_through :browser

  #   get "/", PageController, :home
  # end

  scope "/", Hub88WalletWeb do
    pipe_through :api

    post "/user/balance", UserController, :balance

    post "/transaction/bet", TransactionController, :create_bet
    post "/transaction/win", TransactionController, :create_win
  end

  # Other scopes may use custom stacks.
  # scope "/api", Hub88WalletWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hub88_wallet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Hub88WalletWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
