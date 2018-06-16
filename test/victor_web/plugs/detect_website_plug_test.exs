defmodule VictorWeb.DetectWebsitePlugTest do
  use VictorWeb.ConnCase
  alias VictorWeb.DetectWebsitePlug

  test "finds website", ~M{conn} do
    conn = DetectWebsitePlug.call(conn, nil)
    assert not is_nil(conn.assigns.website)
  end

  test "404s for unknown websites", ~M{conn} do
    conn =
      disable_logs do
        conn
        |> Map.put(:host, "not-a-known-host.com")
        |> DetectWebsitePlug.call(nil)
      end

    assert not Map.has_key?(conn.assigns, :website)
  end
end
