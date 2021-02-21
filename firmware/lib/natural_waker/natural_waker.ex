defmodule NaturalWaker.NaturalWaker do
  require Logger
  use GenServer

  defmodule State do
    defstruct [:alarm_on, :brightness, :config, :timer, :volume]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: NaturalWaker)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, ref} = :timer.send_interval(1000, :tick)
    config = NaturalWaker.DB.get(0)

    state = %State{
      alarm_on: false,
      brightness: 0,
      config: config,
      timer: ref,
      volume: 0
    }

    {:ok, state}
  end

  defp set_color(color) do
    Process.send({NeopixelStick, node()}, {:set_color, color}, [])
  end

  defp set_brightness(level) do
    Process.send({NeopixelStick, node()}, {:set_brightness, level}, [])
  end

  defp set_volume(level) do
    Process.send({VolumeManager, node()}, {:set_volume, level}, [])
  end

  defp in_alarm_range?(time) do
    {:ok, now} = DateTime.now("America/New_York", Tzdata.TimeZoneDatabase)
    local_minutes = round(time / 1000 / 60) - 300

    alarm_hour =
      Integer.floor_div(local_minutes, 60)
      |> case do
        24 -> 0
        x -> x
      end

    alarm_minute = rem(local_minutes, 60)
    now.hour === alarm_hour and now.minute >= alarm_minute and now.minute <= alarm_minute + 5
  end

  defp sleep_mode() do
    set_brightness(0)
    set_volume(0)
  end

  defp activate_alarm(config) do
    Logger.info("activating alarm")
    set_volume(config.volume)
    Process.send({SpeakerBonnet, node()}, {:play_file, config.audio_file}, [])
    set_color(config.color)
    set_brightness(config.brightness)
  end

  defp increment_alarm(state) do
    brightness = if state.brightness >= 255, do: 255, else: state.brightness + 2
    volume = if state.volume >= 60, do: 60, else: state.volume + 1
    set_brightness(brightness)
    set_volume(volume)
    {brightness, volume}
  end

  @impl GenServer
  def handle_info(:get_config, state) do
    config = NaturalWaker.DB.get(0)
    Logger.info(inspect(config))
    {:noreply, state |> struct(%{config: config})}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    if in_alarm_range?(state.config.time) do
      if state.alarm_on === false do
        activate_alarm(state.config)
        {:noreply, state |> struct(%{alarm_on: true, brightness: 10, volume: 20})}
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
