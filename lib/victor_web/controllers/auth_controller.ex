defmodule VictorWeb.AuthController do
  use VictorWeb, :controller

  @claims Poison.encode!(%{id_token: %{email: %{essential: true}}})
  @scope "openid profile"

  def callback(conn, %{"id_token" => id_token, "state" => state}) do
    case get_session(conn, "state") do
      ^state ->
        conn
        |> put_session("id_token", id_token)
        |> redirect(to: "/")

      _ ->
        conn
        |> put_status(401)
        |> text("there was a problem authenticating you")
    end
  end

  def signin(conn, _params) do
    state = SecureRandom.hex()
    nonce = SecureRandom.hex()

    query =
      %{
        state: state,
        nonce: nonce,
        response_type: :id_token,
        client_id: Victor.Auth.client_id(),
        redirect_uri: Victor.Auth.redirect_uri(),
        scope: @scope,
        claims: @claims
      }
      |> Map.merge(Victor.Auth.authorize_params())
      |> URI.encode_query()

    uri =
      Victor.Auth.authorize_url()
      |> URI.parse()
      |> Map.put(:query, query)
      |> to_string()

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
