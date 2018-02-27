defmodule Victor.Auth do
  require Logger
  @jwk_types ["PS512", "RS512", "ES512"]
  @scope "openid email"
  import JOSE.JWT, only: [verify_strict: 3]

  def allowed_to_visit?(website, id_token) do
    with {true, %{fields: fields}, _jws} <-
           verify_strict(website.authentication.public_key, @jwk_types, id_token),
         exp = Timex.from_unix(Map.get(fields, "exp", 0)),
         diff when diff > 0 <- Timex.diff(exp, Timex.now()) do
      Victor.AuthenticationConfig.allowed?(website.authentication, fields)
    else
      error ->
        _ = Logger.error("Not allowed to visit: #{inspect error}")
        false
    end
  end

  def redirect(:visitor, website) do
    URI.parse(website.authentication.visitor_authorize_uri)
    |> redirect(:id_token, website)
  end

  def redirect(:editor, website) do
    URI.parse(website.authentication.editor_authorize_uri)
    |> redirect(:code, website)
  end

  defp redirect(uri, response_type, website) do
    state = SecureRandom.hex()
    nonce = SecureRandom.hex()
    auth_config = website.authentication

    query =
      %{
        state: state,
        nonce: nonce,
        response_type: response_type,
        client_id: auth_config.client_id,
        redirect_uri: auth_config.redirect_uri,
        scope: @scope
      }
      |> Map.merge(URI.decode_query(uri.query))
      |> URI.encode_query()

    uri =
      uri
      |> Map.put(:query, query)
      |> to_string()

    {uri, state, nonce}
  end
end
