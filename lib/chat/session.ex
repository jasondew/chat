defmodule Chat.Session do
  @moduledoc """
  Handles the chat session with a single client.
  """

  defstruct ~w[socket]a

  use GenServer

  require Logger

  alias Chat.{Message, Person, Room}

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  @impl true
  def init(socket) do
    GenServer.cast(Room, {:connected, self()})
    accept_another_message(socket)

    {:ok, %__MODULE__{socket: socket}}
  end

  @impl true
  def handle_info({:tcp, socket, text}, state) do
    message = Message.new(text, Person.new())

    :ok = GenServer.call(Room, {:message, message})
    handle_message(message)
    accept_another_message(socket)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info("Client disconnected: #{inspect(socket)}")
    :ok = GenServer.call(Room, :disconnected)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:send, message}, state) do
    :gen_tcp.send(state.socket, Message.format(message) <> "\n")

    {:noreply, state}
  end

  ## PRIVATE FUNCTIONS

  defp accept_another_message(socket) do
    :inet.setopts(socket, active: :once)
  end

  defp handle_message(%Message{text: "list_rooms"}) do
    Logger.info("I am listing rooms")
  end

  defp handle_message(%Message{text: "join_room " <> room_name}) do
    Logger.info("I am joining the room called '#{room_name}'")
  end

  defp handle_message(%Message{text: "new_room " <> room_name}) do
    Logger.info("I am creating a new room called '#{room_name}'")
  end

  defp handle_message(_otherwise), do: :ignore
end
