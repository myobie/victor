defmodule Victor.AuthTest do
  use Victor.UnitCase, async: true

  alias Victor.Auth

  @keypair JOSE.JWK.from(Application.get_env(:victor, :test_keypair))

  @valid_id_token JOSE.JWT.sign(@keypair, %{
                    iss: "https://vsoexample.com/",
                    sub: 1,
                    aud: "victor",
                    exp: Timex.now() |> Timex.shift(days: 2) |> Timex.to_unix(),
                    iat: Timex.now() |> Timex.to_unix(),
                    auth_time: Timex.now() |> Timex.to_unix(),
                    nonce: "abc",
                    email: "me@vsoexample.com"
                  })
                  |> JOSE.JWS.compact()
                  |> elem(1)

  @expired_id_token JOSE.JWT.sign(@keypair, %{
                      iss: "https://vsoexample.com/",
                      sub: 1,
                      aud: "victor",
                      exp: Timex.now() |> Timex.shift(days: -2) |> Timex.to_unix(),
                      iat: Timex.now() |> Timex.to_unix(),
                      auth_time: Timex.now() |> Timex.to_unix(),
                      nonce: "abc",
                      email: "me@vsoexample.com"
                    })
                    |> JOSE.JWS.compact()
                    |> elem(1)

  @invalid_id_token JOSE.JWT.sign(@keypair, %{
                      iss: "https://vsoexample.com/",
                      sub: 1,
                      aud: "victor",
                      exp: Timex.now() |> Timex.shift(days: 2) |> Timex.to_unix(),
                      iat: Timex.now() |> Timex.to_unix(),
                      auth_time: Timex.now() |> Timex.to_unix(),
                      nonce: "abc",
                      email: "me@somewhereelse.com"
                    })
                    |> JOSE.JWS.compact()
                    |> elem(1)

  setup do
    website = Victor.Websites.get("vsoexample.com")
    {:ok, ~M{website}}
  end

  test "valid tokens are allowed to visit", ~M{website} do
    assert Auth.allowed_to_visit?(website, @valid_id_token)
  end

  test "expired tokens are not allowed to visit", ~M{website} do
    disable_logs do
      refute Auth.allowed_to_visit?(website, @expired_id_token)
    end
  end

  test "invalid tokens are not allowed to visit", ~M{website} do
    refute Auth.allowed_to_visit?(website, @invalid_id_token)
  end

  test "redirects visitors", ~M{website} do
    {uri, _state, _nonce} = Auth.redirect(:visitor, website)
    assert uri =~ ~r{^https://}
    assert uri =~ ~r/=id_token/
  end

  test "redirects editors", ~M{website} do
    {uri, _state, _nonce} = Auth.redirect(:editor, website)
    assert uri =~ ~r{^https://}
    assert uri =~ ~r/=code/
  end
end
