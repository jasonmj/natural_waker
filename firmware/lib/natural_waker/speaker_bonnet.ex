defmodule NaturalWaker.SpeakerBonnet do
  require Logger
  use GenServer

  defmodule State do
    defstruct [:file, :repeat_file]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: SpeakerBonnet)
  end

  @impl GenServer
  def init(_opts) do
    System.cmd("aplay", ["/etc/silence.wav"])
    Process.send({VolumeManager, Node.self()}, {:set_volume, 0}, [])

    state = %State{
      file: nil,
      repeat_file: false
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_info({:play_file, filename}, state) do
    Task.async(fn -> System.cmd("aplay", ["/root/audio/#{filename}"]) end)
    {:noreply, state |> struct(%{file: filename})}
  end

  @impl GenServer
  def handle_info(:set_repeat, state) do
    {:noreply, state |> struct(%{repeat_file: true})}
  end

  @impl GenServer
  def handle_info(:stop_audio, state) do
    Task.async(fn -> System.cmd("killall", ["aplay"]) end)
    {:noreply, %{repeat: false}}
    {:noreply, state |> struct(%{repeat_file: false})}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, :normal}, state) do
    Logger.info("Process ID #{inspect(pid)} exited normally")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({_ref, {"", exit_code}}, state) do
    Logger.info("Task exited with code #{exit_code}")

    if state.repeat_file do
      Process.send(self(), {:play_file, state.file}, [])
      {:noreply, state}
    else
      {:noreply, state |> struct(%{file: nil})}
    end
  end
end
