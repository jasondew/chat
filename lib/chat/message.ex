defmodule Chat.Message do
  defstruct [:from, :text, :timestamp]

  def format(message) do
    "[#{message.timestamp} #{inspect(message.from)}] #{message.text}"
  end
end
