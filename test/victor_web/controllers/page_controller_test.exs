defmodule VictorWeb.PageControllerTest do
  use VictorWeb.ConnCase

  test "GET /anything", %{conn: conn} do
    conn = get(conn, "/anything")
    assert html_response(conn, 404) =~ "not found"
  end
end
