defmodule Chat.Client do
  require Logger

  @host 'localhost'
  @opts [:binary, active: false]

  def run() do
    port =
      String.to_integer(System.get_env("PORT") || raise("missing $PORT environment variable"))
    Logger.info("I have started the client")
    {:ok, socket} = :gen_tcp.connect(@host, port, @opts)
    run(socket)
  end

  ### PRIVATE FUNCTIONS

  def run(socket) do
    run(socket)
  end
end
