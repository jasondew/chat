defmodule Chat.Person do
  defstruct ~w[id name]a

  alias ExULID.ULID

  def new() do
    new("Anonymous")
  end

  def new(name) do
    %__MODULE__{id: ULID.generate(), name: name}
  end
end
