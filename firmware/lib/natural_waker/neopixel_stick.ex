defmodule NaturalWaker.NeopixelStick do
  use GenServer
  require Logger

  alias Blinkchain.Point
  alias Blinkchain.Color

  @alarm_hour 6
  @alarm_minute 15
  @warm_yellow Color.parse("#FFCB00")
  @lights_out Color.parse("#000000")

  defmodule State do
    defstruct [:alarm_on, :brightness, :timer, :volume]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, ref} = :timer.send_interval(3000, :draw_frame)

    state = %State{
      alarm_on: false,
      brightness: 0,
      timer: ref,
      volume: 0
    }

    set_the_lights(@warm_yellow)
    Blinkchain.render()
    System.cmd("aplay", ["/etc/silence.wav"])
    System.cmd("amixer", ["sset", "PCM", "0%"])

    {:ok, state}
  end

  defp set_the_lights(color) do
    Blinkchain.set_pixel(%Point{x: 0, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 1, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 2, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 3, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 4, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 5, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 6, y: 0}, color)
    Blinkchain.set_pixel(%Point{x: 7, y: 0}, color)
  end

  defp set_volume(level) do
    System.cmd("amixer", ["sset", "PCM", "#{level}%"])
  end

  def handle_info(:draw_frame, state) do
    {:ok, now} = DateTime.now("America/New_York", Tzdata.TimeZoneDatabase)

    in_alarm_range =
      now.hour === @alarm_hour and now.minute >= @alarm_minute and now.minute <= @alarm_minute + 6

    if in_alarm_range do
      if state.alarm_on === false do
        set_the_lights(@warm_yellow)
        Blinkchain.set_brightness(0, 1)
        Blinkchain.render()
        set_volume(20)
        Process.send({:speakerbonnet, Node.self()}, :start_audio, [])
        Process.send_after({:speakerbonnet, Node.self()}, :start_audio, 3 * 60 * 1000)
        {:noreply, state |> struct(%{alarm_on: true, brightness: 0, volume: 20})}
      else
        volume_level = if state.volume >= 80, do: 80, else: state.volume + 1
        set_volume(volume_level)
        brightness = if state.brightness >= 255, do: 255, else: state.brightness + 1
        Blinkchain.set_brightness(0, brightness)
        Blinkchain.render()

        {:noreply,
         state |> struct(%{brightness: brightness, alarm_on: true, volume: volume_level})}
      end
    else
      if state.alarm_on === true do
        set_the_lights(@lights_out)
        set_volume(0)
        Blinkchain.render()
        {:noreply, state |> struct(%{alarm_on: false, brightness: 0, volume: 0})}
      else
        {:noreply, state}
      end
    end
  end
end
