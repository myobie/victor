defmodule VictorWeb.AuthController do
  use VictorWeb, :controller

  def signin(conn, _params) do
    conn
    |> put_session("authenticated", true)
    |> redirect(to: "/")
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
