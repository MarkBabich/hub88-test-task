defmodule Hub88WalletWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use Hub88WalletWeb, :controller` and
  `use Hub88WalletWeb, :live_view`.
  """
  use Hub88WalletWeb, :html

  embed_templates "layouts/*"
end
