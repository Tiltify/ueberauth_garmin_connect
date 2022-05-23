defmodule UeberauthGarminConnect.Mixfile do
  use Mix.Project

  @source_url "https://github.com/tiltify/ueberauth_garmin_connect"
  @version "0.0.1"

  def project do
    [
      app: :ueberauth_garmin_connect,
      version: @version,
      name: "Ueberauth Garmin Connect Strategy",
      package: package(),
      elixir: "~> 1.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      homepage_url: @source_url,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :oauther, :ueberauth]]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8.0"},
      {:oauther, "~> 1.3.0"},
      {:ueberauth, "~> 0.6"},
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, ">= 0.0.0", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "An Uberauth strategy for Garmin Connect authentication.",
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Tiltify"],
      licenses: ["MIT"]
    ]
  end
end
