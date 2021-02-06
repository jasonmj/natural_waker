defmodule NaturalWaker.NeopixelStick do
  use GenServer

  alias Blinkchain.Point
  alias Blinkchain.Color

  @warm_yellow Color.parse("#FFCB00FF")
  @lights_out Color.parse("#00000000")

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: :neopixel_stick)
  end

  @impl GenServer
  def init(_opts) do
    set_brightness(0)
    {:ok, %{}}
  end

  defp set_the_lights(color) do
    Enum.each(0..7, fn x -> Blinkchain.set_pixel(%Point{x: x, y: 0}, color) end)
  end

  defp set_brightness(level) do
    if level > 0 do
      set_the_lights(@warm_yellow)
    else
      set_the_lights(@lights_out)
    end
    Blinkchain.set_brightness(0, level)
    Blinkchain.render()
  end

  @impl GenServer
  def handle_info({:set_brightness, level}, state) do
    set_brightness(level)
    {:noreply, state}
  end
end
