defmodule NaturalWaker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_all, name: NaturalWaker.Supervisor]

    children = [] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    []
  end

  def children(_target) do
    [
      NaturalWaker.ConfigDB,
      NaturalWaker.NeopixelStick,
      NaturalWaker.SpeakerBonnet,
      NaturalWaker.VolumeManager,
      NaturalWaker.NaturalWaker
    ]
  end

  def target() do
    Application.get_env(:natural_waker, :target)
  end
end
