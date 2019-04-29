defmodule Chat.Client do
  require Logger

  @host 'localhost'
  @opts [:binary, active: false]

  @recognized_commands """
  /?          Shows this list
  /create foo Creates a new room with the name 'foo'
  /join foo   Join the room with the name 'foo'
  /list_rooms Lists the current rooms
  /q          Quits the client
  """

  def run() do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))

    {:ok, socket} = :gen_tcp.connect(@host, port, @opts)
    receive_command(socket)
  end

  ### PRIVATE FUNCTIONS

  defp execute_command("/?", socket) do
    IO.puts(@recognized_commands)
    receive_command(socket)
  end

  defp execute_command("/join " <> room_name, socket) do
    IO.puts("TODO: join room with name '#{room_name}'")
    write_line(socket, "/join " <> room_name)
    receive_command(socket)
  end

  defp execute_command("/list_rooms", socket) do
    IO.puts("TODO: list rooms")
    write_line(socket, "/list_rooms")
    receive_command(socket)
  end

  defp execute_command("/create " <> room_name, socket) do
    IO.puts("TODO: new room with name '#{room_name}'")
    write_line(socket, "/create " <> room_name)
    receive_command(socket)
  end

  defp execute_command("/q", _socket) do
    System.halt()
  end

  defp execute_command(chat_message, socket) do
    write_line(socket, chat_message)
    receive_command(socket)
  end

  defp receive_command(socket) do
    "\nPlease provide a command. /? for options> "
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> execute_command(socket)
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line <> "\r\n")
  end
end
