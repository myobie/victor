defmodule VictorWeb.StaticWebsitePlugTest do
  import ShorterMaps
  use VictorWeb.ConnCase
  alias VictorWeb.StaticWebsitePlug

  setup ~M{conn} do
    conn = assign(conn, :website, List.first(Victor.Websites.config()))
    {:ok, ~M{conn}}
  end

  test "serves a file", ~M{conn} do
    conn =
      conn
      |> Map.put(:path_info, ["index.html"])
      |> StaticWebsitePlug.call(nil)

    assert %{halted: true} = conn
    assert 200 == conn.status
  end

  test "serves the index file of a directory", ~M{conn} do
    conn =
      conn
      |> Map.put(:path_info, [])
      |> StaticWebsitePlug.call(nil)

    assert %{halted: true} = conn
  end

  test "doesn't serve missing files", ~M{conn} do
    conn =
      conn
      |> Map.put(:path_info, ["foo"])
      |> StaticWebsitePlug.call(nil)

    assert %{halted: false} = conn
  end
end
