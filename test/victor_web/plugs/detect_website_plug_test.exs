defmodule VictorWeb.DetectWebsitePlugTest do
  import ShorterMaps
  use VictorWeb.ConnCase
  alias VictorWeb.DetectWebsitePlug

  test "finds website", ~M{conn} do
    conn = DetectWebsitePlug.call(conn, nil)
    assert not is_nil(conn.assigns.website)
  end

  test "404s for unknown websites", ~M{conn} do
    Logger.disable(self())

    conn =
      conn
      |> Map.put(:host, "not-a-known-host.com")
      |> DetectWebsitePlug.call(nil)

    Logger.enable(self())

    assert not Map.has_key?(conn.assigns, :website)
  end
end
