defmodule Chat.Client do
  require Logger

  @host "localhost"
  @port 42019

  def run() do
    Logger.info("I have started the client")
    {:ok, socket} = :gen_tcp.connect(@host, @port, [{:active, true}])
    run(socket)
  end

  ### PRIVATE FUNCTIONS

  def run(socket) do
    run(socket)
  end
end
