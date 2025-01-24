defmodule Inject.MixProject do
  use Mix.Project
  @version "0.4.1"

  def project do
    [
      app: :inject,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      deps: [],
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/sonerdy/inject"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Inject.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :inject,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Brandon Joyce"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/sonerdy/inject",
        "Docs" => "https://github.com/sonerdy/inject"
      }
    ]
  end

  defp description do
    """
    Inject is a library that lets you write testable Elixir code that can run concurrently in ExUnit.
    """
  end
end
