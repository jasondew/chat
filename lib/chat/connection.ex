defmodule Chat.Connection do
  require Logger

  alias Chat.{ConnectionSupervisor, Message, Room}

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :line, active: false, reuseaddr: true]
      )

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(ConnectionSupervisor, fn -> connect(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  def connect(socket) do
    GenServer.cast(Room, {:connection, socket})
    serve(socket)
  end

  def serve(socket) do
    case read_line(socket) do
      {:ok, %Message{} = message} ->
        Logger.info("Received '#{Message.format(message)}'")
        handle_message(message)
        GenServer.cast(Room, {:message, message, socket})
        serve(socket)

      {:error, :closed} ->
        GenServer.cast(Room, {:disconnection, socket})

      {:error, :enotconn} ->
        Logger.warn("Tried to read from a closed socket.")
    end
  end

  ### PRIVATE FUNCTIONS

  defp handle_message(%Message{text: "list_rooms"}) do
    Logger.info("I am listing rooms")
  end

  defp handle_message(%Message{text: "new_room " <> room_name}) do
    Logger.info("I am creating a new room called '#{room_name}'")
  end

  defp handle_message(other), do: :ignore

  defp read_line(socket) do
    {:ok, text} = :gen_tcp.recv(socket, 0)
    {:ok, %Message{text: String.trim_trailing(text, "\r\n"), timestamp: DateTime.utc_now()}}
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end
end
