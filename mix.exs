defmodule Logdna.MixProject do
  use Mix.Project

  def project do
    [
      app: :logdna,
      version: "0.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: [extras: ["README.md"]],
      source_url: "https://github.com/Waasi/logdna"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp description do
    "Logdna Logger Backend"
  end

  defp package do
    [
      name: :logdna,
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: ["Eric Santos"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Waasi/logdna"}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.6"},
      {:mock, "~> 0.3.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
