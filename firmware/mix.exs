defmodule NaturalWaker.MixProject do
  use Mix.Project

  @app :natural_waker
  @version "0.1.0"
  @all_targets [:custom_rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {NaturalWaker.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7.0", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},
      {:tzdata, "~> 1.1"},

      # Circuits projects
      {:circuits_uart, "~> 1.3"},
      {:circuits_gpio, "~> 0.4"},
      {:circuits_i2c, "~> 0.3"},
      {:circuits_spi, "~> 0.1"},
      {:power_control, github: "cjfreeze/power_control"},
      {:ui, path: "../ui", env: Mix.env()},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},
      {:blinkchain, "~> 1.0", targets: @all_targets},
      {:nerves_time, "~> 0.4.2", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.13.3", runtime: false, targets: :rpi0},
      {:custom_rpi0,
       path: "../custom_rpi0", runtime: false, targets: :custom_rpi0, nerves: [compile: true]},

      # Local dependencies
      {:mix_tasks_upload_hotswap, "~> 0.1.0", only: :dev}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
