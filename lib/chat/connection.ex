defmodule Chat.Connection do
  require Logger

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

    {:ok, pid} =
      Task.Supervisor.start_child(
        Chat.ConnectionSupervisor,
        fn -> connect(client) end
      )

    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  def connect(socket) do
    GenServer.cast(Chat.Room, {:connection, socket})
    serve(socket)
  end

  def serve(socket) do
    case read_line(socket) do
      {:ok, message} ->
        Logger.info("Received '#{inspect(message)}'")
        message |> String.trim_trailing("\r\n") |> handle_message()
        GenServer.cast(Chat.Room, {:message, message, socket})
        serve(socket)

      {:error, :closed} ->
        GenServer.cast(Chat.Room, {:disconnection, socket})

      {:error, :enotconn} ->
        Logger.warn("Tried to read from a closed socket.")
    end
  end

  ### PRIVATE FUNCTIONS

  defp handle_message("list_rooms") do
    Logger.info("I am listing rooms")
  end

  defp handle_message("new_room " <> room_name) do
    Logger.info("I am creating a new room called '#{room_name}'")
  end

  defp handle_message(other), do: :ignore

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end
end
