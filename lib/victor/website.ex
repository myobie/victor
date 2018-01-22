defmodule Victor.Website do
  defstruct host: nil,
            scheme: "https:",
            git_repo: %Victor.GitRepo{},
            authentication: nil

  @type t :: %__MODULE__{host: String.t(), git_repo: Victor.GitRepo.t()}

  @spec url(t) :: String.t()
  def url(website) do
    "#{website.scheme}//#{website.host}/"
  end
end

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

defmodule Victor.AuthenticationConfig.Verifier do
  defstruct type: nil, content: nil

  @type types :: :everyone | :email_ends_with? | :email_starts_with? | :email_contains?

  @type t :: %__MODULE__{type: types, content: String.t()}

  def allowed?(%__MODULE__{type: :everyone}, _user_info), do: true

  def allowed?(%__MODULE__{type: :email_ends_with?, content: content}, %{email: email}),
    do: String.ends_with?(email, content)

  def allowed?(%__MODULE__{type: :email_starts_with?, content: content}, %{email: email}),
    do: String.starts_with?(email, content)

  def allowed?(%__MODULE__{type: :email_contains?, content: content}, %{email: email}),
    do: String.contains?(email, content)

  def allowed?(_, _), do: false
end
