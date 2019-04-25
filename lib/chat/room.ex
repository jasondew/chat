defmodule Chat.Room do
  @enforce_keys ~w[id name]a
  defstruct id: nil, name: nil, sessions: MapSet.new(), messages: []

  use GenServer

  require Logger

  alias Chat.Message
  alias ExULID.ULID

  def name(room) do
    GenServer.cast(room, {:get_name, self()})

    receive do
      {:name, name} -> name
    end
  end

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
    send_text(session, "Welcome to ##{state.name}!")

    {:noreply, updated_state}
  end

  def handle_cast({:disconnected, session}, state) do
    {:noreply, %{state | sessions: MapSet.delete(state.sessions, session)}}
  end

  def handle_cast({:message, message, session}, state) do
    send_message_to_all_other_sessions(state.sessions, session, message)

    {:noreply, %{state | messages: [message | state.messages]}}
  end

  @impl true
  def handle_cast({:get_name, callback}, state) do
    send(callback, {:name, state.name})
    {:noreply, state}
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
    GenServer.cast(session, {:send_message, message})
  end
end
