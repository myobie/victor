defmodule VictorWeb.AuthController do
  use VictorWeb, :controller

  def callback(_conn, %{"code" => _code, "state" => _state}) do
    # Will be the callback for the editor flow
    raise "not implemented"
  end

  def callback(conn, %{"id_token" => id_token, "state" => state}) do
    with ^state <- get_session(conn, "state"),
         true <- Victor.Auth.allowed_to_visit?(conn.assigns.website, id_token) do
      # TODO: just set the info into the session so we don't have to re-verify the id_token every request
      conn
      |> delete_session("state")
      |> put_session("id_token", id_token)
      |> redirect(to: "/")

      # TODO: make the redirect configurable
    else
      _ -> four_oh_one(conn)
    end
  end

  @spec four_oh_one(Plug.Conn.t()) :: Plug.Conn.t()
  defp four_oh_one(conn) do
    conn
    |> delete_session("state")
    |> put_status(401)
    |> text("there was a problem authenticating you")
  end

  def signin(conn, %{"style" => "visitor"}), do: signin_redirect(conn, :visitor)
  def signin(conn, %{"style" => "editor"}), do: signin_redirect(conn, :editor)

  defp signin_redirect(conn, type) do
    {uri, state, nonce} = Victor.Auth.redirect(type, conn.assigns.website)

    conn
    |> put_session("state", state)
    |> put_session("nonce", nonce)
    |> redirect(external: uri)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
