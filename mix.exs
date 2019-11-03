defmodule EctoReflection.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_reflection,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      test: ["test --trace"]
    ]
  end
end
