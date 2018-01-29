defmodule Victor.AuthenticationConfig do
  alias Victor.AuthenticationConfig.Verifier

  # TODO: support a list of public_keys

  defstruct visitor_authorize_uri: nil,
            editor_authorize_uri: nil,
            client_id: nil,
            redirect_uri: nil,
            public_key: nil,
            verifiers: []

  @type t :: %__MODULE__{
          visitor_authorize_uri: String.t(),
          editor_authorize_uri: String.t(),
          client_id: String.t(),
          redirect_uri: String.t(),
          public_key: String.t(),
          verifiers: [Verifier.t()]
        }

  @spec allowed?(t, map) :: boolean
  def allowed?(%__MODULE__{verifiers: verifiers}, info),
    do: Enum.any?(verifiers, & Verifier.allowed?(&1, info))
end
