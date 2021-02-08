defmodule NaturalWaker.SpeakerBonnet do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: :speaker_bonnet)
  end

  @impl GenServer
  def init(_opts) do
    System.cmd("aplay", ["/etc/silence.wav"])
    Process.send({:volume_manager, Node.self()}, {:set_volume, 0}, [])
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:start_audio, state) do
    Task.async(fn -> System.cmd("aplay", ["/etc/birds.wav"]) end)
    {:noreply, state}
  end

end
