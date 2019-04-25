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
    "[#{formatted_timestamp(message)} #{message.from.name}] #{message.text}"
  end

  def timestamp(message) do
    message.id
    |> ULID.decode()
    |> elem(0)
    |> DateTime.from_unix!(:millisecond)
  end

  defp formatted_timestamp(message) do
    datetime = timestamp(message)
    date_part = "#{datetime.year}-#{two_digit(datetime.month)}-#{two_digit(datetime.day)}"
    {hour, am_or_pm} = twelve_hour_time(datetime.hour)
    time_part = "#{two_digit(hour)}:#{two_digit(datetime.minute)}#{am_or_pm}"

    "#{date_part}@#{time_part}"
  end

  defp twelve_hour_time(hour) when hour > 12 do
    {hour - 12, "PM"}
  end

  defp twelve_hour_time(hour) when hour <= 12 do
    {hour, "AM"}
  end

  defp two_digit(integer) do
    integer
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
