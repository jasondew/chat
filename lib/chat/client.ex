defmodule Chat.Client do
  require Logger

  @host 'localhost'
  @opts [:binary, active: false]

  @recognized_commands """
?       Shows this list
lr      Lists the current rooms
nr foo  Creates a new room with the name 'foo'
q       Quits the client
"""

  def run() do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))
    Logger.info("I have started the client")
    {:ok, socket} = :gen_tcp.connect(@host, port, @opts)
    receive_command(socket)
  end

  ### PRIVATE FUNCTIONS

  defp execute_command("?", socket) do
    IO.puts(@recognized_commands)
    receive_command(socket)
  end

  defp execute_command("lr", socket) do
    IO.puts("TODO: list rooms")
    write_line(socket, "list rooms")
    receive_command(socket)
  end

  defp execute_command("nr " <> room_name, socket) do
    IO.puts("TODO: new room with name '#{room_name}'")
    write_line(socket, "new room " <> room_name)
    receive_command(socket)
  end

  defp execute_command("q", _socket) do
    System.halt()
  end

  defp execute_command(other, socket) do
    IO.puts("I do not understand '#{other}'")
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
