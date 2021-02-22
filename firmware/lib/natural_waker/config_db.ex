defmodule NaturalWaker.ConfigDB do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: ConfigDB)
  end

  @impl GenServer
  def init(state) do
    :mnesia.stop()
    :net_kernel.monitor_nodes(true)
    start_node()
    {:ok, state}
  end

  defp start_node() do
    Logger.info("Starting node app@naturalwaker.local")
    System.cmd("epmd", ["-daemon"])
    Node.start(:"app@naturalwaker.local")
    Node.set_cookie(Application.get_env(:mix_tasks_upload_hotswap, :cookie))
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    Logger.info("Node connected: #{inspect(node)}")

    ensure_schema()
    connect_mnesia_to_cluster()

    {:noreply, state}
  end

  @impl true
  def handle_info({:nodedown, node}, state) do
    Logger.info("Node disconnected: #{inspect(node)}")

    update_mnesia_nodes()

    {:noreply, state}
  end

  defp ensure_schema() do
    Logger.info("Ensuring schema on #{node()}")

    case :mnesia.create_schema([node()]) do
      :ok ->
        Logger.info("Created schema on #{node()}")

      {:error, {node, {:already_exists, _}}} ->
        Logger.info("Schema already exists on #{node}")

      error ->
        Logger.error("Something went wrong while creating schema on #{node()}: #{inspect(error)}")
        error
    end
  end

  defp connect_mnesia_to_cluster() do
    Logger.info("Starting mnesia on #{node()}")

    :mnesia.start()

    ensure_table_exists()
  end

  defp update_mnesia_nodes do
    nodes = Node.list()

    Logger.info("Updating Mnesia nodes with #{inspect(nodes)}")

    :mnesia.change_config(:extra_db_nodes, nodes)
  end

  defp ensure_table_exists() do
    Logger.info("Ensuring table exists: ConfigDB")

    :mnesia.create_table(ConfigDB, attributes: [:id, :val], disc_copies: [node()])
  end

  defp get(id) do
    t = fn -> :mnesia.read({ConfigDB, id}) end

    case :mnesia.transaction(t) do
      {:atomic, [{_tab, ^id, val}]} ->
        val

      {:atomic, []} ->
        nil

      error ->
        Logger.error("Error in get: #{inspect(error)}")
        error
    end
  end

  defp put(id, val) do
    t = fn -> :mnesia.write({ConfigDB, id, val}) end

    case :mnesia.transaction(t) do
      {:atomic, :ok} ->
        Logger.info("Successfully saved record ID #{id} to ConfigDB")

      {:atomic, []} ->
        nil

      error ->
        Logger.error("Error in put: #{inspect(error)}")
        error
    end
  end

  @impl true
  def handle_call({:get, id}, _pid, state) do
    config = get(id)
    {:reply, config, state}
  end

  @impl true
  def handle_cast({:put, {id, val}}, state) do
    put(id, val)
    {:noreply, state}
  end
end
