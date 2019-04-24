defmodule Chat.Session do
  @moduledoc """
  Handles the chat session with a single client.
  """

  defstruct ~w[socket room]a

  use GenServer

  require Logger

  alias Chat.{Message, Person, Room, Server}

  def start_link({socket, room}) do
    GenServer.start_link(__MODULE__, {socket, room})
  end

  @impl true
  def init({socket, room}) do
    GenServer.cast(room, {:connected, self()})
    accept_another_message(socket)

    {:ok, %__MODULE__{socket: socket, room: room}}
  end

  @impl true
  def handle_info({:tcp, socket, text}, state) do
    message = Message.new(text, Person.new())
    updated_state = handle_message(message, state)
    accept_another_message(socket)

    {:noreply, updated_state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info("Client disconnected: #{inspect(socket)}")
    :ok = GenServer.call(state.room, :disconnected)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:send_message, message}, state) do
    send_to_socket(state.socket, Message.format(message))

    {:noreply, state}
  end

  ## PRIVATE FUNCTIONS

  defp accept_another_message(socket) do
    :inet.setopts(socket, active: :once)
  end

  defp send_to_socket(socket, text) do
    :gen_tcp.send(socket, text <> "\n")
  end

  defp handle_message(%Message{text: "/list_rooms"}, state) do
    encoded_room_names =
      Server.room_names()
      |> Enum.join(",")

    send_to_socket(state.socket, encoded_room_names)

    state
  end

  defp handle_message(%Message{text: "/whereami"}, state) do
    send_to_socket(state.socket, "You are in #{Room.name(state.room)}.")
    state
  end

  defp handle_message(%Message{text: "/join " <> room_name}, state) do
    join_room(state, Server.find_room(room_name))
  end

  defp handle_message(%Message{text: "/create " <> room_name}, state) do
    {:ok, new_room} = Server.start_room(room_name)
    join_room(state, new_room)
  end

  defp handle_message(message, state) do
    :ok = GenServer.call(state.room, {:message, message})
    state
  end

  defp join_room(state, new_room) do
    GenServer.cast(new_room, {:connected, self()})
    Map.put(state, :room, new_room)
  end
end
