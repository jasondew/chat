defmodule Chat.Message do
  defstruct [:id, :from, :text]

  alias Chat.Person
  alias ExULID.ULID

  def new(text) do
    new(text, Person.new("SYSTEM"))
  end

  def new(text, person) do
    text = String.trim_trailing(text)
    %__MODULE__{id: ULID.generate(), text: text, from: person}
  end

  def format(message) do
    "[#{timestamp(message)} #{inspect(message.from)}] #{message.text}"
  end

  def timestamp(message) do
    message.id
    |> ULID.decode()
    |> elem(0)
  end
end
