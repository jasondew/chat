defmodule Chat.Server do
  use DynamicSupervisor

  require Logger

  alias Chat.Session

  @default_port 42019

  def start(port \\ @default_port) do
    Logger.info("Accepting connections on port #{port}")

    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :line, active: false, reuseaddr: true]
      )

    Task.async(fn -> accept_connection(socket) end)
  end

  def start_link(opts \\ []) do
    opts = Keyword.put(opts, :name, __MODULE__)

    DynamicSupervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_session(client) do
    {:ok, _session} = DynamicSupervisor.start_child(__MODULE__, {Session, client})
  end

  def terminate_session(session) do
    DynamicSupervisor.terminate_child(__MODULE__, session)
  end

  def sessions do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(&elem(&1, 1))
  end

  def session_count do
    DynamicSupervisor.count_children(__MODULE__)
  end

  defp accept_connection(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, session} = start_session(client)
    :ok = :gen_tcp.controlling_process(client, session)

    accept_connection(socket)
  end
end
