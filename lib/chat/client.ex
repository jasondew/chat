defmodule Chat.Client do

  require Logger

  def run(:init) do
    Logger.info("I have started the client")
    run()
  end

  def run(), do: run()
end
