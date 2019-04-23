defmodule Chat.Client do
  require Logger

  @host 'localhost'
  @opts [:binary, active: false]

  alias Chat.Message

  def run() do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))
    Logger.info("I have started the client")
    {:ok, socket} = :gen_tcp.connect(@host, port, @opts)
    receive_command(socket)
  end

  ### PRIVATE FUNCTIONS

  defp execute_command("?", socket) do
    IO.puts "TODO: recognized commands"
    receive_command(socket)
  end

  defp execute_command("lr", socket) do
    IO.puts "TODO: list rooms"
    write_line(socket, "list rooms")
    receive_command(socket)
  end

  defp execute_command("nr " <> room_name, socket) do
    IO.puts "TODO: new room with name '#{room_name}'"
    write_line(socket, "new room " <> room_name)
    receive_command(socket)
  end

  defp execute_command("q", _socket) do
    IO.puts "\nConnection lost"
  end

  defp execute_command(other, socket) do
    receive_command(socket)
  end

  defp receive_command(socket) do
    "\nPlease provide a command. ? for options> "
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> execute_command(socket)
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end
end
