defmodule Coincoin.Token.Mixfile do
  use Mix.Project

  def project do
    [
      app: :coincoin_token,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6-dev",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger], mod: {Coincoin.Token.Application, []}]
  end

  defp deps do
    [
      {:coincoin_blockchain, in_umbrella: true}
    ]
  end
end
