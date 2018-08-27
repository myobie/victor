defmodule Victor.Repo.Migrations.CreateWebsitesTable do
  use Ecto.Migration

  alias Victor.Website.SchemeEnum

  def change do
    SchemeEnum.create_type()

    create table("websites") do
      add(:host, :string, size: 1024, null: false)
      add(:scheme, SchemeEnum.type(), null: false, default: "https")
      add(:repo, :map, null: false)
      add(:remote, :map, null: false)

      timestamps()
    end
  end
end
