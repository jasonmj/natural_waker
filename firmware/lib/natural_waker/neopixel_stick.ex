defmodule NaturalWaker.NeopixelStick do
  require Logger
  use GenServer

  alias Blinkchain.Point
  alias Blinkchain.Color

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: NeopixelStick)
  end

  @impl GenServer
  def init(_opts) do
    Logger.info("Initializing neopixel stick")
    set_color("#FFCB00")
    set_brightness(10)
    set_brightness(0)
    {:ok, %{}}
  end

  defp set_color(color) do
    Enum.each(0..7, fn x -> Blinkchain.set_pixel(%Point{x: x, y: 0}, Color.parse(color)) end)
    Blinkchain.render()
  end

  defp set_brightness(level) do
    Blinkchain.set_brightness(0, level)
    Blinkchain.render()
  end

  @impl GenServer
  def handle_info({:set_brightness, level}, state) do
    set_brightness(level)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:set_color, color}, state) do
    set_color(color)
    {:noreply, state}
  end
end
