defmodule Chat.Client do
  require Logger

  @host "localhost"

  def run() do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))
    Logger.info("I have started the client")
    {:ok, socket} = :gen_tcp.connect(@host, port, [{:active, true}])
    run(socket)
  end

  ### PRIVATE FUNCTIONS

  def run(socket) do
    run(socket)
  end
end
