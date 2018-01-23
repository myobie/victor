defmodule Victor.AuthenticationConfig do
  alias Victor.AuthenticationConfig.Verifier

  defstruct authorize_url: nil,
            redirect_uri: nil,
            public_key: nil,
            verifiers: []

  @type t :: %__MODULE__{
          authorize_url: String.t(),
          redirect_uri: String.t(),
          public_key: String.t(),
          verifiers: [Verifier.t()]
        }

  def allowed?(%__MODULE__{verifiers: verifiers}, user_info),
    do: Enum.any?(verifiers, & &1.allowed?(user_info))
end
