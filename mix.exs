defmodule EctoReflection.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_reflection,
      version: "0.1.0",
      elixir: "~> 1.11.1",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
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

  defp elixirc_paths(env) when env in [:test, :dev] do
    ["lib", "test/support"]
  end

  defp elixirc_paths(_), do: ["lib"]

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
