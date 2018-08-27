defmodule Victor.Website do
  use Ecto.Schema

  @type t :: %__MODULE__{}

  import EctoEnum
  defenum(SchemeEnum, :website_scheme_enum, [:http, :https])

  schema "websites" do
    field(:host, :string)
    field(:scheme, SchemeEnum)

    embeds_one(:repo, Victor.GitRepo)
    embeds_one(:remote, Victor.GitRemote)

    timestamps()
  end

  @spec url(t) :: String.t()
  def url(website) do
    "#{website.scheme}//#{website.host}/"
  end
end
