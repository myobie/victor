defmodule Victor.Auth do
  @open_id_connect_config Application.get_env(:victor, :open_id_connect)
  @authorize_url Keyword.get(@open_id_connect_config, :authorize_url)
  @authorize_params Keyword.get(@open_id_connect_config, :authorize_params, %{})
  @client_id Keyword.get(@open_id_connect_config, :client_id)
  @public_key Keyword.get(@open_id_connect_config, :public_key)
  @token_verifier Keyword.get(@open_id_connect_config, :token_verifier, {Victor.Auth, :empty_verifier})
  @default_callback_path URI.parse("/app/auth/callback")

  def config, do: @open_id_connect_config
  def authorize_url, do: @authorize_url
  def authorize_params, do: @authorize_params
  def client_id, do: @client_id
  def public_key, do: @public_key
  def empty_verifier(_), do: true

  def redirect_uri do
    case Keyword.get(@open_id_connect_config, :redirect_uri) do
      nil ->
        URI.parse(VictorWeb.Endpoint.url())
        |> URI.merge(@default_callback_path)
        |> to_string()
      uri -> uri
    end
  end

  def valid?(fields) do
    {m, f} = @token_verifier
    apply(m, f, [fields])
  end
end
