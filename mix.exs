defmodule HedwigIrc.Mixfile do
  use Mix.Project
  @description """
    An IRC adapter for Hedwig
  """

  def project do
    [
      app: :hedwig_irc,
      version: "0.1.4",
      elixir: "~> 1.2",
      name: "hedwig_irc",
      description: @description,
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :hedwig, :exirc]]
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
      {:hedwig, "~> 1.0"},
      {:exirc, "~> 1.0"},
      {:ex_doc, "~> 0.18", only: :dev},
    ]
  end

  defp package do
    [
      maintainers: ["Jeff Weiss"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffweiss/hedwig_irc"},
    ]
  end
end
