defmodule Woke.MixProject do
  use Mix.Project

  def project do
    [
      app: :woke,
      version: "0.1.1",
      elixir: "~> 1.10",
      deps: deps(),
      ddocs: [extras: ["README.md"], main: "RADME.md", source_ref: "v0.1.1"],
      source_url: "https://github.com/lorenzosinisi/woke",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description do
    """
    Watchdog design patter library for Elixir applications
    """
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Lorenzo Sinisi"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/lorenzosinisi/woke"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
