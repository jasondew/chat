defmodule Chat.Room do
  defstruct members: MapSet.new(), messages: []

  alias Chat.Message

  require Logger
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{}, opts)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:debug, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:connection, socket}, state) do
    updated_state = %{state | members: MapSet.put(state.members, socket)}

    Logger.info("Got a connection from #{inspect(socket)}.")
    Logger.info("Current connections:")
    Enum.each(updated_state.members, &Logger.info("  - #{inspect(&1)}"))

    replay_history(state.messages, socket)

    {:noreply, updated_state}
  end

  def handle_cast({:message, text, socket}, state) do
    message = %Message{from: socket, text: text, timestamp: Time.utc_now()}
    send_message_to_all_other_members(state.members, socket, message)

    {:noreply, %{state | messages: [message | state.messages]}}
  end

  def handle_cast({:disconnection, socket}, state) do
    {:noreply, %{state | members: MapSet.delete(state.members, socket)}}
  end

  defp replay_history(messages, member) do
    messages
    |> Enum.reverse()
    |> Enum.each(&send_message(&1, member))
  end

  defp send_message_to_all_other_members(members, excluded_member, message) do
    members
    |> Enum.each(fn member ->
      if member != excluded_member do
        send_message(message, member)
      end
    end)
  end

  defp send_message(message, member) do
    :gen_tcp.send(member, Message.format(message))
  end
end
