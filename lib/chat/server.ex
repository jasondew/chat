defmodule Chat.Server do
  use DynamicSupervisor

  require Logger

  alias Chat.{Room, Session}

  @default_port 42019
  @default_room "#general"

  def start_link(opts \\ []) do
    opts = Keyword.put(opts, :name, __MODULE__)

    DynamicSupervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start(port \\ @default_port) do
    Logger.info("Accepting connections on port #{port}")

    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :line, active: false, reuseaddr: true]
      )

    {:ok, default_room} = start_room(@default_room)

    Task.async(fn -> accept_connection(socket, default_room) end)
  end

  ## ROOMS

  def start_room(name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Room, name}
    )
  end

  def rooms do
    children(Room)
  end

  ## SESSIONS

  def start_session(client, default_room) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Session, {client, default_room}}
    )
  end

  def sessions do
    children(Session)
  end

  ## PRIVATE METHODS

  defp accept_connection(socket, default_room) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, session} = start_session(client, default_room)
    :ok = :gen_tcp.controlling_process(client, session)

    accept_connection(socket, default_room)
  end

  defp children(module) do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.filter(&(elem(&1, 3) == [module]))
    |> Enum.map(&elem(&1, 1))
  end
end
