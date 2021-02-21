defmodule UiWeb.PageLive do
  require Logger
  use UiWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    audio_files = File.ls!(audio_dir())
    config = get_config()

    {:ok,
     socket
     |> assign(:audio_files, audio_files)
     |> assign(:audio_file, config.audio_file)
     |> assign(:color, config.color)
     |> assign(:brightness, config.brightness)
     |> assign(:volume, config.volume)
     |> assign(:time, config.time)
     |> allow_upload(:audio, accept: ~w(.wav), max_entries: 1)}
  end

  defp audio_dir() do
    system_env = System.get_env("SYSTEM") || "device"
    if system_env == "host", do: "/home/nerves/audio", else: "/root/audio"
  end

  defp get_config() do
    system_env = System.get_env("SYSTEM") || "device"

    if system_env == "host" do
      %{
        color: "#000000",
        brightness: 0,
        audio_file: "birds.wav",
        volume: 0,
        time: 43_200_000
      }
    else
      NaturalWaker.ConfigDB.get(0)
    end
  end

  @impl true
  def handle_event("volume_change", %{"value" => level}, socket) do
    Logger.info("Volume changed to #{Integer.to_string(level)}")
    Process.send({VolumeManager, Node.self()}, {:set_volume, level}, [])
    {:noreply, assign(socket, volume: level)}
  end

  @impl true
  def handle_event("color_change", %{"value" => color}, socket) do
    Logger.info("Color changed to #{color}")
    Process.send({NeopixelStick, Node.self()}, {:set_color, color}, [])
    {:noreply, assign(socket, color: color)}
  end

  @impl true
  def handle_event("brightness_change", %{"value" => level}, socket) do
    Logger.info("Brightness changed to #{Integer.to_string(level)}")
    Process.send({NeopixelStick, Node.self()}, {:set_brightness, level}, [])
    {:noreply, assign(socket, brightness: level)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    Logger.info("Validating uploads")
    {:noreply, socket}
  end

  @impl true
  def handle_event("file_change", %{"value" => file}, socket) do
    Logger.info("File changed to #{file}")
    {:noreply, assign(socket, audio_file: file)}
  end

  @impl true
  def handle_event("upload_files", _params, socket) do
    Logger.info("New file uploaded")

    uploaded_files =
      consume_uploaded_entries(socket, :audio, fn %{path: path}, entry ->
        Logger.info(entry.client_name)
        dest = Path.join(audio_dir(), entry.client_name)
        File.cp!(path, dest)
        Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
      end)

    audio_files = File.ls!(audio_dir())
    {:noreply, assign(socket, audio_files: audio_files)}
  end

  @impl true
  def handle_event("start_audio", %{"value" => ""}, socket) do
    Logger.info("Starting audio")
    Process.send({SpeakerBonnet, Node.self()}, :start_audio, [])
    {:noreply, socket}
  end

  @impl true
  def handle_event("play_file", %{"filename" => filename}, socket) do
    Logger.info("Playing file #{filename}")
    Process.send({SpeakerBonnet, Node.self()}, {:play_file, filename}, [])
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_file", %{"filename" => filename}, socket) do
    Logger.info("Deleting file #{filename}")
    System.cmd("rm", ["#{audio_dir()}/#{filename}"])
    audio_files = File.ls!(audio_dir())
    {:noreply, assign(socket, audio_files: audio_files)}
  end

  @impl true
  def handle_event("stop_audio", _params, socket) do
    Logger.info("Stopping audio")
    Process.send({SpeakerBonnet, Node.self()}, :stop_audio, [])
    {:noreply, socket}
  end

  @impl true
  def handle_event("time_change", %{"value" => time}, socket) do
    Logger.info("Time changed to #{time}")
    {:noreply, assign(socket, time: time)}
  end

  @impl true
  def handle_event("save_config", _params, socket) do
    Logger.info("Saving config")

    new_config = %{
      color: socket.assigns.color,
      brightness: socket.assigns.brightness,
      audio_file: socket.assigns.audio_file,
      volume: socket.assigns.volume,
      time: socket.assigns.time
    }

    NaturalWaker.ConfigDB.put(0, new_config)
    Process.send({NaturalWaker, Node.self()}, :get_config, [])
    {:noreply, socket}
  end
end
