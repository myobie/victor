defmodule VictorWeb.DetectWebsitePlug do
  @behaviour Plug
  import Plug.Conn
  require Logger

  @type config :: [fallback: Victor.Website.t()]

  @spec init() :: config
  @spec init(config | [] | nil) :: config

  def init, do: init(%{})

  def init(fallback: fallback), do: %{fallback: fallback}
  def init([]), do: %{fallback: nil}
  def init(nil), do: %{fallback: nil}

  def call(conn, %{fallback: fallback}) do
    case Victor.Websites.get(conn.host) do
      nil -> assign(conn, :website, fallback)
      site -> assign(conn, :website, site)
    end
  end
end
