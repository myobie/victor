defmodule Victor.Websites do
  @raw_config Application.get_env(:victor, :websites)
  @config for c <- @raw_config, do: Victor.Website.Config.parse(c)

  def config, do: @config
end
