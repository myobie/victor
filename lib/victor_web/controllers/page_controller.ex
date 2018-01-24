defmodule VictorWeb.PageController do
  use VictorWeb, :controller

  def find(_conn, _segments) do
  end

  def not_found(conn, _params) do
    conn
    |> put_status(404)
    |> html("not found")
  end
end
