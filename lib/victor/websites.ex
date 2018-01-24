defmodule Victor.Websites do
  @raw_config Application.get_env(:victor, :websites)
  @config for c <- @raw_config, do: Victor.Website.Config.parse(c)

  def config, do: @config

  @spec get(String.t()) :: Victor.Website.t() | nil
  def get(host) do
    Enum.find(config(), &(&1.host == host))
  end

  @spec fetch(String.t()) :: {:ok, Victor.Website.t()} | :error
  def fetch(host) do
    case get(host) do
      nil -> :error
      site -> {:ok, site}
    end
  end
end
