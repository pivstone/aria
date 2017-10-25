defmodule Accelerator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :accelerator,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: "A Docker Registry accelerator.",
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      mod: {Accelerator, []},
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.4"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:magic, "~> 0.3.0"},
      {:gen_stage, "~> 0.12.1"},
    ]
  end
end
