defmodule Chat.Room do
  @enforce_keys ~w[id name]a
  defstruct id: nil, name: nil, sessions: MapSet.new(), messages: []

  use GenServer

  require Logger

  alias Chat.Message
  alias ExULID.ULID

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  @impl true
  def init(name) do
    {:ok, %__MODULE__{id: ULID.generate(), name: name}}
  end

  @impl true
  def handle_info(:debug, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:connected, session}, state) do
    updated_state = %{state | sessions: MapSet.put(state.sessions, session)}
    send_text(session, "Welcome to #{state.name}! You're connected as #{inspect(session)}.")

    {:noreply, updated_state}
  end

  @impl true
  def handle_call(:disconnected, {session, _reference}, state) do
    {:reply, :ok, %{state | sessions: MapSet.delete(state.sessions, session)}}
  end

  def handle_call({:message, message}, {session, _reference}, state) do
    send_message_to_all_other_sessions(state.sessions, session, message)

    {:reply, :ok, %{state | messages: [message | state.messages]}}
  end

  defp send_message_to_all_other_sessions(sessions, excluded_session, message) do
    sessions
    |> Enum.each(fn session ->
      if session != excluded_session do
        send_message(session, message)
      end
    end)
  end

  defp send_text(session, text) do
    send_message(session, Message.new(text))
  end

  defp send_message(session, message) do
    GenServer.cast(session, {:send, message})
  end
end
