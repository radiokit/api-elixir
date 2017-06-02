defmodule RadioKit.Mixfile do
  use Mix.Project

  def project do
    [app: :radiokit_api,
     version: "0.3.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :stag or Mix.env == :prod,
     start_permanent: Mix.env == :stag or Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.11"},
      {:poison, "~> 2.0 or ~> 3.1"},
      {:exvcr, "~> 0.8.9", only: :test}
    ]
  end
end
