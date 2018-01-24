defmodule VictorWeb.DetectWebsitePlug do
  @behaviour Plug
  import Plug.Conn
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    case Victor.Websites.get(conn.host) do
      nil -> not_found(conn)
      site -> assign(conn, :website, site)
    end
  end

  defp not_found(conn) do
    _ = Logger.error "Cannot find website for '#{conn.host}'"

    conn
    |> put_resp_content_type("text/plain")
    |> resp(404, "Not found")
  end
end
