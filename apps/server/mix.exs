defmodule Server.Mixfile do
  use Mix.Project

  def project do
    [
      app: :server,
      version: "0.3.0",
      elixir: "~> 1.4",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Server, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.

  defp deps do
    [
      {:api, in_umbrella: true},
      {:dashboard, in_umbrella: true},
      {:phoenix, "~> 1.2.1"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
    ]
  end

end
