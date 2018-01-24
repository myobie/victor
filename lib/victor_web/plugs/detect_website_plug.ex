defmodule VictorWeb.DetectWebsitePlug do
  @behaviour Plug
  import Plug.Conn
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    case Victor.Websites.get(conn.host) do
      nil -> conn
      site -> assign(conn, :website, site)
    end
  end
end
