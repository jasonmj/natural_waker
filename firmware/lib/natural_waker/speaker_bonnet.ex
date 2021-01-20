defmodule NaturalWaker.SpeakerBonnet do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: :speakerbonnet)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_info(:start_audio, state) do
    System.cmd("aplay", ["/etc/birds.wav"])
    {:noreply, state}
  end
end
