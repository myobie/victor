defmodule Victor.Auth do
  require Logger
  @jwk_types ["PS512", "RS512", "ES512"]
  @scope "openid email"
  import JOSE.JWT, only: [verify_strict: 3]

  def allowed_to_visit?(website, id_token) do
    with {:ok, fields} <- verify_public_key(website, id_token),
         :ok <- is_not_expired(fields) do
      Victor.AuthenticationConfig.allowed?(website.authentication, fields)
    else
      error ->
        _ = Logger.error("Not allowed to visit: #{inspect(error)}")
        false
    end
  end

  defp verify_public_key(website, id_token) do
    result = verify_strict(website.authentication.public_key, @jwk_types, id_token)

    case result do
      {true, %{fields: fields}, _jws} -> {:ok, fields}
      _ -> {:error, :verification_failed}
    end
  end

  defp is_not_expired(fields) do
    exp =
      fields
      |> Map.get("exp", 0)
      |> Timex.from_unix()

    if Timex.diff(exp, Timex.now()) > 0 do
      :ok
    else
      {:error, :already_expired}
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
