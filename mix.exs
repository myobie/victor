defmodule Victor.Mixfile do
  use Mix.Project

  def project do
    [
      app: :victor,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_add_deps: :transitive,
        flags: [
          :unmatched_returns,
          :error_handling,
          :race_conditions,
          :underspecs,
          :no_behaviours,
          :no_fail_call,
          :no_missing_calls,
          :no_return,
          :no_undefined_callbacks,
          :no_unused
        ]
      ],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Victor.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:secure_random, "~> 0.5.1"},
      {:jose, "~> 1.8"},
      {:yaml_elixir, "~> 1.3"},
      {:shorter_maps, "~> 2.2"},
      {:timex, "~> 3.1"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: ["compile", "dialyzer"]
    ]
  end
end
