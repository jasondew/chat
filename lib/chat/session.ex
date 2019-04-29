defmodule Chat.Session do
  @moduledoc """
  Handles the chat session with a single client.
  """

  defstruct ~w[socket person room]a

  use GenServer

  require Logger

  alias Chat.{Message, Person, Room, Server}

  def start_link({socket, room}) do
    GenServer.start_link(__MODULE__, {socket, room}, debug: [:trace])
  end

  @impl true
  def init({socket, room}) do
    GenServer.cast(room, {:connected, self()})
    accept_another_message(socket)
    state = %__MODULE__{socket: socket, person: Person.new(), room: room}

    {:ok, state}
  end

  @impl true
  def handle_info({:tcp, socket, text}, state) do
    message = Message.new(text, state.person)
    updated_state = handle_message(message, state)
    accept_another_message(socket)

    {:noreply, updated_state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info("Client disconnected: #{inspect(socket)}")
    GenServer.cast(state.room, {:disconnected, self()})

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

  defp handle_message(%Message{text: "/alias " <> new_name}, state) do
    send_to_socket(state.socket, "You are now known as #{new_name}.")
    put_in(state.person.name, new_name)
  end

  defp handle_message(%Message{text: "/whereami"}, state) do
    send_to_socket(state.socket, "You are in ##{Room.name(state.room)}.")
    state
  end

  defp handle_message(%Message{text: "/whoami"}, state) do
    send_to_socket(state.socket, "You are #{state.person.name}.")
    state
  end

  defp handle_message(%Message{text: "/join " <> room_name}, state) do
    case Server.find_room(room_name) do
      new_room when not is_nil(new_room) ->
        join_room(state, new_room)

      _ ->
        send_to_socket(state.socket, "Error joining ##{inspect(room_name)}")
        state
    end
  end

  defp handle_message(%Message{text: "/create " <> room_name}, state) do
    {:ok, new_room} = Server.start_room(room_name)
    join_room(state, new_room)
  end

  defp handle_message(message, state) do
    GenServer.cast(state.room, {:message, message, self()})
    state
  end

  defp join_room(state, new_room) when not is_nil(new_room) do
    GenServer.cast(state.room, {:disconnected, self()})
    GenServer.cast(new_room, {:connected, self()})
    Map.put(state, :room, new_room)
  end
end
