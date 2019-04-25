defmodule ChatTest do
  use ExUnit.Case
  doctest Chat

  alias Chat.Server

  test "creating and joining a room" do
    Logger.configure(level: :warn)
    Server.start()

    # connect and create #random
    socket1 = connect()
    read_line(socket1)

    write_line(socket1, "/whereami")
    assert read_line(socket1) == "You are in #general."

    write_line(socket1, "/create random")
    read_line(socket1)

    write_line(socket1, "/whereami")
    assert read_line(socket1) == "You are in #random."

    # connect and join #random
    socket2 = connect()
    read_line(socket2)

    write_line(socket2, "/join random")
    read_line(socket2)

    write_line(socket2, "/whereami")
    assert read_line(socket2) == "You are in #random."

    # connect and stay in #general
    socket3 = connect()
    read_line(socket3)

    # send a message in #random from client 1, client 2 should see it
    write_line(socket1, "what up")
    assert read_line(socket2) |> String.ends_with?("what up")
    assert_no_new_messages(socket3)

    # send a message in #general, clients 1 and 2 shouldn't see it
    write_line(socket3, "um, guys?")
    assert_no_new_messages(socket1)
    assert_no_new_messages(socket2)

    # disconnect all clients
    disconnect(socket1)
    disconnect(socket2)
    disconnect(socket3)

    assert Server.room_names() == ~w[general random]
  end

  defp connect() do
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 42019, [:binary, active: false])
    socket
  end

  defp read_line(socket) do
    {:ok, line} = :gen_tcp.recv(socket, 0, 100)
    String.trim_trailing(line)
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line <> "\n")
  end

  defp disconnect(socket) do
    :gen_tcp.close(socket)
  end

  defp assert_no_new_messages(socket) do
    {:error, :timeout} = :gen_tcp.recv(socket, 0, 50)
  end
end
