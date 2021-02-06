defmodule NaturalWaker.NaturalWaker do
  use GenServer

  @alarm_hour 6
  @alarm_minute 15

  defmodule State do
    defstruct [:alarm_on, :brightness, :timer, :volume]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, ref} = :timer.send_interval(2500, :tick)

    state = %State{
      alarm_on: false,
      brightness: 0,
      timer: ref,
      volume: 0
    }

    {:ok, state}
  end

  defp set_brightness(level) do
    Process.send({:neopixel_stick, Node.self()}, {:set_brightness, level}, [])
  end

  defp set_volume(level) do
    Process.send({:volume_manager, Node.self()}, {:set_volume, level}, [])
  end

  defp in_alarm_range?() do
    {:ok, now} = DateTime.now("America/New_York", Tzdata.TimeZoneDatabase)
    now.hour === @alarm_hour and now.minute >= @alarm_minute and now.minute <= @alarm_minute + 5
  end

  defp sleep_mode() do
    set_brightness(0)
    set_volume(0)
  end

  defp activate_alarm() do
    set_brightness(1)
    set_volume(20)
    Process.send({:speaker_bonnet, Node.self()}, :start_audio, [])
  end

  defp increment_alarm(state) do
    brightness = if state.brightness >= 255, do: 255, else: state.brightness + 1
    volume = if state.volume >= 80, do: 80, else: state.volume + 1
    set_brightness(brightness)
    set_volume(volume)
    {brightness, volume}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    if in_alarm_range?() do
      if state.alarm_on === false do
        activate_alarm()
        {:noreply, state |> struct(%{alarm_on: true, brightness: 0, volume: 20})}
      else
        {brightness, volume} = increment_alarm(state)
        {:noreply, state |> struct(%{brightness: brightness, alarm_on: true, volume: volume})}
      end
    else
      if state.alarm_on === true do
        sleep_mode()
        {:noreply, state |> struct(%{alarm_on: false, brightness: 0, volume: 0})}
      else
        {:noreply, state}
      end
    end
  end
end
