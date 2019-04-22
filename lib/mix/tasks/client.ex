defmodule Mix.Tasks.Client do
  use Mix.Task

  def run(_), do: Chat.Client.run(:init)
end
