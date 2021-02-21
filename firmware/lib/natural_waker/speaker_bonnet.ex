defmodule NaturalWaker.SpeakerBonnet do
  require Logger
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: SpeakerBonnet)
  end

  @impl GenServer
  def init(_opts) do
    System.cmd("aplay", ["/etc/silence.wav"])
    Process.send({VolumeManager, Node.self()}, {:set_volume, 0}, [])
    {:ok, %{}}
  end

  @impl GenServer
  def handle_info(:start_audio, state) do
    Task.start(fn -> System.cmd("aplay", ["/root/audio/birds.wav"]) end)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:play_file, filename}, state) do
    Task.async(fn -> System.cmd("aplay", ["/root/audio/#{filename}"]) end)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:stop_audio, state) do
    Task.async(fn -> System.cmd("killall", ["aplay"]) end)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, :normal}, state) do
    Logger.info("Process ID #{inspect(pid)} exited normally")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({_ref, {"", exit_code}}, state) do
    Logger.info("Task exited with code #{exit_code}")
    {:noreply, state}
  end
end
