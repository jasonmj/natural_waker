defmodule NaturalWaker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: NaturalWaker.Supervisor]

    if Application.get_env(:natural_waker, :env) == :dev do
      System.cmd("epmd", ["-daemon"])
      Node.start(:"naturalwaker@nerves.local")
      Node.set_cookie(Application.get_env(:mix_tasks_upload_hotswap, :cookie))
    end

    children = [] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    []
  end

  def children(_target) do
    [
      NaturalWaker.NeopixelStick,
      NaturalWaker.SpeakerBonnet
    ]
  end

  def target() do
    Application.get_env(:natural_waker, :target)
  end
end
