defmodule Victor.AuthenticationConfig.Verifier do
  defstruct type: nil, content: nil

  @type types ::
          :everyone
          | :email_ends_with?
          | :email_starts_with?
          | :email_contains?
          | :email_is_one_of?

  @type t :: %__MODULE__{type: types, content: String.t()}

  def allowed?(%__MODULE__{type: :everyone}, _user_info), do: true

  def allowed?(%__MODULE__{type: :email_ends_with?, content: content}, %{"email" => email}),
    do: String.ends_with?(email, content)

  def allowed?(%__MODULE__{type: :email_starts_with?, content: content}, %{"email" => email}),
    do: String.starts_with?(email, content)

  def allowed?(%__MODULE__{type: :email_contains?, content: content}, %{"email" => email}),
    do: String.contains?(email, content)

  def allowed?(%__MODULE__{type: :email_is_one_of?, content: content}, %{"email" => email}),
    do: Enum.member?(content, email)

  def allowed?(_, _), do: false
end
