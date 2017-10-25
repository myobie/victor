defmodule VictorWeb.PageController do
  use VictorWeb, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(404)
    |> text("not found")
  end
end
