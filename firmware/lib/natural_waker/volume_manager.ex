defmodule NaturalWaker.VolumeManager do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: :volume_manager)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info({:set_volume, level}, state) do
    System.cmd("amixer", ["sset", "PCM", "#{level}%"])
    {:noreply, state}
  end
end
